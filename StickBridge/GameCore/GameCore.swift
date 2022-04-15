import Foundation
import SwiftUI
import Combine

class GameCore: ObservableObject {
    
    private var timer = Timer.publish (every: 0.01, on: .current, in: .common)
    private var storage = Set<AnyCancellable>()
    
    @Published private(set) var state: GameState = .notStarted
    @Published private(set) var score = 0
    private(set) var bonus = 0
    
    @Published private(set) var startPillar: Pillar
    @Published private(set) var targetPillar: Pillar
    @Published private(set) var sparePillar: Pillar

    @Published private(set) var bridgeHeight: CGFloat = 0
    
    @Published private(set) var animationKeyFrames = [KeyFrame]()
    
    @AppStorage(AppStorageKey.maxScore.rawValue) private(set) var maxScore: Int = 0
    @AppStorage(AppStorageKey.gradient.rawValue) private(set) var gradient: GradientColor = .orange
    
    private var ballOffsetX: CGFloat {
        -screenCenter + startPillar.width - (Config.Ball.size / 2)
    }
    
    var bridgeOffsetX: CGFloat {
        -screenCenter + startPillar.width
    }
    
    private let pillarGenerator: PillarGenerator
    private let feedbackGenerator: ActionFeedbackGenerator
    
    init(
        pillarGenerator: PillarGenerator = PillarGenerator.shared,
        feedbackGenerator: ActionFeedbackGenerator = ActionFeedbackGenerator()
    ) {
        self.pillarGenerator = pillarGenerator
        self.feedbackGenerator = feedbackGenerator
        let pillars = pillarGenerator.generateInitialPillars()
        startPillar = pillars.start
        targetPillar = pillars.target
        sparePillar = pillars.spare
        
        state = .started
        animationKeyFrames = [.initial(ballOffsetX: ballOffsetX)]
        log("Game has started", category: .gameCore)
    }
    
    private func onTimerTick() {
        let maxHeight = max((screenWidth - startPillar.endX), 0)
        if bridgeHeight + Config.Bridge.deltaPerTick >= maxHeight { return }
        bridgeHeight += Config.Bridge.deltaPerTick
    }
    
    private func rollTheBall() {
        /// actual bridge end x
        let bridgeEndX = startPillar.endX + bridgeHeight
        let didHitTarget = targetPillar.didHit(bridgeEndX: bridgeEndX)
        let didHitCenter = targetPillar.didHitCenter(x: bridgeEndX)
        
        /// here we calculate on what x we should roll the ball
        /// if we didn't hit the target pillar, we roll the ball till the bridge end
        /// if we did hit the target pillar, we roll the ball till the target pillar end
        let finalOffsetX = didHitTarget ? -screenCenter + targetPillar.endX - Config.Ball.radius : -screenCenter + bridgeEndX - Config.Ball.radius
        
        let horizontalBridge = KeyFrame.horizontalBridge()
        /// delay before bridge is set horizontally
        let placingBridgeDelay = horizontalBridge.duration
        let rollingTheBall = KeyFrame.rollingTheBall(ballOffsetX: finalOffsetX, distance: finalOffsetX - ballOffsetX, delay: placingBridgeDelay)
        
        var animations = [
            horizontalBridge,
            rollingTheBall
        ]

        if didHitTarget {
            log("Did hit target", category: .gameCore)
            if didHitCenter {
                bonus += 1
                animations.append(.preparePerfectHit(delay: placingBridgeDelay))
                animations.append(.perfectHit(delay: placingBridgeDelay))
                feedbackGenerator.feedback(onAction: .didHitTargetCenter, with: placingBridgeDelay)
                log("Did hit center. Bonus: \(bonus)", category: .gameCore)
            } else {
                bonus = 0
                animations.append(.targetCenterFading(delay: placingBridgeDelay))
                feedbackGenerator.feedback(onAction: .didHitTarget, with: placingBridgeDelay)
            }

            // shifting pillars to the left so target becomes the start one
            let newPillars = pillarGenerator.shiftPillars((startPillar, targetPillar, sparePillar))
            let futurePosition = screenWidth - newPillars.target.startX
            animations.append(.movingField(baseFieldOffset: -targetPillar.startX, sparePillarOffset: -futurePosition, delay: rollingTheBall.endTime))

            let stepEndTime = animations.endTime
            completeStep(withDelay: stepEndTime) { [weak self] in
                self?.nextStep(newPillars)
            }
        } else {
            animations.append(.fallenBridge(delay: rollingTheBall.endTime))
            feedbackGenerator.feedback(onAction: .didFailToHitTarget, with: placingBridgeDelay)
            log("Failed to hit target", category: .gameCore)
            
            let stepEndTime = animations.endTime
            completeStep(withDelay: stepEndTime) { [weak self] in
                guard let self = self else { return }
                self.maxScore = max(self.maxScore, self.score)
                self.state = .finished
            }
        }
        state = .animating
        animationKeyFrames = animations
    }
    
    private func nextStep(_ pillars: PillarsSet) {
        score = score + bonus + 1
        bridgeHeight = 0
        startPillar = pillars.start
        targetPillar = pillars.target
        sparePillar = pillars.spare
        animationKeyFrames = [.initial(ballOffsetX: ballOffsetX)]
        state = .started
        log("Next step. Game score: \(score)", category: .gameCore)
    }
    
    func restartGame() {
        initPillars()
        bridgeHeight = 0
        score = 0
        bonus = 0
        animationKeyFrames = [.initial(ballOffsetX: ballOffsetX)]
        state = .started
        log("Game has restarted", category: .gameCore)
    }
    
    func onLongPressStarted() {
        cancelTimer()
        timer = Timer.publish (every: 0.01, on: .current, in: .common)
        timer.sink(receiveValue: { [weak self] _ in
                self?.onTimerTick()
            })
            .store(in: &storage)
        timer.connect().store(in: &storage)
        feedbackGenerator.feedback(onAction: .longPressStarted, with: 0.0)
        log("Long press started", category: .gameCore)
    }
    
    func onLongPressEnded() {
        cancelTimer()
        log("Long press ended", category: .gameCore)
        feedbackGenerator.feedback(onAction: .longPressEnded, with: 0.0)
        rollTheBall()
    }
    
    private func cancelTimer() {
        storage.forEach { $0.cancel() }
        storage.removeAll()
    }
    
    func toggleBackground() {
        gradient = gradient.next()
        log("Gradient has changed", category: .gameCore)
    }
    
    func pause() {
        state = .paused
        log("Game is paused", category: .gameCore)
    }
    
    func resume() {
        state = .started
        log("Game is resumed", category: .gameCore)
    }
}

// MARK: - Helpers -

extension GameCore {
    
    private func initPillars() {
        let pillars = pillarGenerator.generateInitialPillars()
        startPillar = pillars.start
        targetPillar = pillars.target
        sparePillar = pillars.spare
    }
    
    private func completeStep(withDelay delay: Double, completion: @escaping () -> ()) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * Double(NSEC_PER_SEC)))
            await MainActor.run {
                completion()
            }
        }
    }
}

enum GameState {
    case notStarted
    case started
    case animating
    case paused
    case finished
}

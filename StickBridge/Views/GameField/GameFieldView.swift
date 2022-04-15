import SwiftUI

struct GameFieldView: View {
    @StateObject private var core = GameCore()
    
    @State private var ballOffsetX: CGFloat = 0.0
    @State private var ballOffsetY: CGFloat = 0.0
    @State private var bridgeAngle: CGFloat = 0.0
    @State private var baseFieldOffset: CGFloat = 0.0
    @State private var sparePillarOffset: CGFloat = 0.0
    
    @State private var bonusTitleScale = 1.0
    @State private var bonusTitleOpacity = 0.0
    
    @State private var targetCenterScale = 1.0
    @State private var targetCenterOpacity = 1.0
    
    @State private var bonusValueScale = 1.0
    @State private var bonusValueOpacity = 0.0
    
    var targetCenterOffsetX: CGFloat {
        -screenCenter + core.targetPillar.centerX + baseFieldOffset
    }
    
    var targetCenterOffsetY: CGFloat {
        screenHeight / 2 - Config.Pillar.height + Config.Pillar.Center.height / 2
    }
        
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("\(core.score)")
                    .font(.system(size: 50))
                    .padding(.top, 100)
                Spacer()
                
                BallView()
                    .offset(x: ballOffsetX + baseFieldOffset , y: ballOffsetY)

                PillarsView(
                    startPillar: core.startPillar,
                    targetPillar: core.targetPillar,
                    sparePillar: core.sparePillar,
                    baseFieldOffset: baseFieldOffset,
                    sparePillarOffset: sparePillarOffset,
                    bonus: core.bonus
                )
                .overlay(
                    BridgeView(height: core.bridgeHeight)
                        .rotationEffect(Angle.degrees(bridgeAngle))
                        .offset(x: core.bridgeOffsetX + baseFieldOffset, y: -core.bridgeHeight - Config.Bridge.width / 2),
                    alignment: .top
                )
            }
            .contentShape(TouchAreaShape())
            // looks like "minimumDuration" actually means "maximumDuration"
            .if(core.state == .started) {
                $0.onLongPressGesture(
                    minimumDuration: 10,
                    perform: {},
                    onPressingChanged: { value in
                    if value {
                        core.onLongPressStarted()
                    } else {
                        core.onLongPressEnded()
                    }
                })
            }
            
            Group {
                targetCenter
                bonusValueText
                    .offset(y: -20)
            }
            .offset(x: targetCenterOffsetX, y: targetCenterOffsetY)
            
            bonusTitle
            if core.state != .finished && core.state != .paused {
                settings
                    .offset(y: -screenHeight / 2 + UIConstants.settingsTopPadding)
            }
            
            if(core.state == .finished || core.state == .paused) {
                GameOverOverlay(state: core.state, score: core.score) {
                    if core.state == .finished {
                        core.restartGame()
                    } else {
                        // TODO rename
                        core.resume()
                    }
                }
            }
        }
        .background(GradientView(gradient: core.gradient))
        .onReceive(core.$animationKeyFrames, perform: { frames in
            resolveAnimations(frames)
        })
        .ignoresSafeArea(.all)
    }
    
    var settings: some View {
        HStack {
            Image("cup")
                .resizable()
                .frame(width: UIConstants.settingsImageSize, height: UIConstants.settingsImageSize)
            Text("\(core.maxScore)")
                .font(.title2)
            Spacer()
            ColorPickerView(color: core.gradient.dark)
                .onTapGesture {
                    core.toggleBackground()
                }
            Image("pause")
                .resizable()
                .frame(width: UIConstants.settingsImageSize, height: UIConstants.settingsImageSize)
                .onTapGesture {
                    core.pause()
                }
        }
        .padding(.horizontal)
        .padding(.top, UIConstants.settingsTopPadding)
    }
    
    var bonusTitle: some View {
        Text(Config.Bonus.title)
            .font(.title2)
            .frame(maxWidth: .infinity)
            .scaleEffect(bonusTitleScale)
            .opacity(bonusTitleOpacity)
    }
    
    var targetCenter: some View {
        let config = Config.Pillar.Center.self
        return Rectangle()
            .fill(config.color)
            .frame(width: config.size, height: config.height)
            .scaleEffect(x: targetCenterScale, y: targetCenterScale, anchor: .top)
            .opacity(targetCenterOpacity)
    }
    
    var bonusValueText: some View {
        Text("+\(core.bonus)")
            .font(.title2)
            .scaleEffect(x: bonusValueScale, y: bonusValueScale, anchor: .bottomLeading)
            .opacity(bonusValueOpacity)
    }
    
    private func resolveAnimations(_ frames: [KeyFrame]) {
        frames.forEach { keyFrame in
            var completion = {}
            switch keyFrame.animationFrame {
            case let .initial(newBallOffsetX, angle):
                completion = {
                    ballOffsetX = newBallOffsetX
                    bridgeAngle = angle.rawValue
                    
                    ballOffsetY = 0.0
                    baseFieldOffset = 0.0
                    sparePillarOffset = 0.0
                    
                    targetCenterScale = 1.0
                    targetCenterOpacity = 1.0
                }
            case let .rollingTheBall(newBallOffsetX):
                completion = {
                    ballOffsetX = newBallOffsetX
                }
            case let .horizontalBridge(angle):
                completion = {
                    bridgeAngle = angle.rawValue
                }
            case let .fallenBridge(angle, newBallOffsetY):
                completion = {
                    bridgeAngle = angle.rawValue
                    ballOffsetY = newBallOffsetY
                }
            case let .movingField(newBaseFieldOffset, newSparePillarOffset):
                completion = {
                    baseFieldOffset = newBaseFieldOffset
                    sparePillarOffset = newSparePillarOffset
                }
            case .preparePerfectHit:
                completion = {
                    bonusTitleScale = 1.0
                    bonusValueScale = 1.0
                    
                    bonusTitleOpacity = 1.0
                    bonusValueOpacity = 1.0
                }
            case let .perfectHit(bonusScale, centerScale):
                completion = {
                    bonusTitleScale = bonusScale
                    bonusTitleOpacity = 0.0
                    
                    targetCenterScale = centerScale
                    targetCenterOpacity = 0.0

                    bonusValueScale = bonusScale
                    bonusValueOpacity = 0.0
                }
            case .targetCenterFading:
                completion = {
                    targetCenterOpacity = 0.0
                }
            }
            
            let animationResolvingBlock = {
                if let animation = keyFrame.animation {
                    withAnimation(animation) {
                        completion()
                    }
                } else {
                    completion()
                }
            }
            if keyFrame.delay == 0.0 {
                animationResolvingBlock()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + keyFrame.delay) {
                    animationResolvingBlock()
                }
            }
        }
    }
}

struct GameFieldView_Previews: PreviewProvider {
    static var previews: some View {
        GameFieldView()
    }
}

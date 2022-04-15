import Foundation
import SwiftUI
import AVFoundation

enum Action: CaseIterable {
    case longPressStarted
    case longPressEnded
    case didHitTarget
    case didHitTargetCenter
    case didFailToHitTarget
    
    var resource: String? {
        switch self {
        case .longPressStarted:
            return "charging"
        case .longPressEnded:
            return nil
        case .didHitTarget:
            return "rustle"
        case .didHitTargetCenter:
            return "success"
        case .didFailToHitTarget:
            return "failure"
        }
    }
}

class ActionFeedbackGenerator {
    
    @AppStorage(AppStorageKey.isSoundOn.rawValue) private var isSoundOn = true
    @AppStorage(AppStorageKey.isVibroOn.rawValue) private var isVibroOn = true
    
    var player: AVAudioPlayer?
    
    func feedback(onAction action: Action, with delay: Double) {
        if isVibroOn {
            switch action {
            case .didHitTargetCenter:
                hapticFeedback(.success, delay: delay)
            case .didFailToHitTarget:
                hapticFeedback(.error, delay: delay)
            default:
                break
            }
        }
        if isSoundOn {
            playSound(forAction: action, with: delay)
        }
    }
    
    private func hapticFeedback(_ feedback: UINotificationFeedbackGenerator.FeedbackType, delay: Double) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * Double(NSEC_PER_SEC)))
            await UINotificationFeedbackGenerator().notificationOccurred(feedback)
        }
    }
    
    private func playSound(forAction action: Action, with delay: Double) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * Double(NSEC_PER_SEC)))
            do {
                guard let resource = action.resource, let path = Bundle.main.path(forResource: resource, ofType:"mp3") else { return }
                let url = URL(fileURLWithPath: path)
                
                player?.stop()
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch let error {
                log("Failed to play sound for action \(action) with error: \(error.localizedDescription)", category: .feedbackGenerator)
            }
            
        }
    }
}

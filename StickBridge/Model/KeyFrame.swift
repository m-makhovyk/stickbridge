import SwiftUI

enum AnimationFrame {
    /// restoring default game field parameters
    case initial(newBallOffsetX: CGFloat, angle: Config.Bridge.Angle)
    
    /// moving the ball over the bridge
    case rollingTheBall(newBallOffsetX: CGFloat)
    
    /// rotating the bridge to place it between pillars
    case horizontalBridge(angle: Config.Bridge.Angle)
    
    /// "breaking" the bridge and dropping the ball in case of failure
    case fallenBridge(angle: Config.Bridge.Angle, newBallOffsetY: CGFloat)
    
    /// shifting pillars for the next step
    case movingField(newBaseFieldOffset: CGFloat, newSparePillarOffset: CGFloat)
    
    /// displaying bonus value and "Perfect" string
    case preparePerfectHit
    
    /// scaling and fading  bonus value and "Perfect" string
    case perfectHit(bonusScale: Double, centerScale: Double)
    
    /// fading target pillar center point before the next step
    case targetCenterFading
}

struct KeyFrame {
    let duration: Double
    let delay: Double
    let animation: Animation?
    let animationFrame: AnimationFrame
    
    var endTime: Double {
        delay + duration
    }
}

extension KeyFrame {
    
    static func initial(ballOffsetX: CGFloat) -> KeyFrame {
        .init(duration: 0, delay: 0, animation: nil, animationFrame: .initial(newBallOffsetX: ballOffsetX, angle: .vertical))
    }
    
    static func rollingTheBall(ballOffsetX: CGFloat, distance: CGFloat, delay: CGFloat) -> KeyFrame {
        let duration = abs(distance) / Config.Ball.speed / 10
        let animationFrame = AnimationFrame.rollingTheBall(newBallOffsetX: ballOffsetX)
        return .init(duration: duration, delay: delay, animation: .linear(duration: duration), animationFrame: animationFrame)
    }
    
    static func horizontalBridge() -> KeyFrame {
        let duration = Config.Animations.medium
        return .init(duration: duration, delay: 0, animation: .easeIn(duration: duration), animationFrame: .horizontalBridge(angle: .horizontal))
    }
    
    static func fallenBridge(delay: Double) -> KeyFrame {
        let duration = Config.Animations.short
        let animationFrame = AnimationFrame.fallenBridge(angle: .fallen, newBallOffsetY: Config.Pillar.height + Config.Ball.size)
        return .init(duration: duration, delay: delay, animation: .easeIn(duration: duration), animationFrame: animationFrame)
    }
    
    static func movingField(baseFieldOffset: CGFloat, sparePillarOffset: CGFloat, delay: Double) -> KeyFrame {
        let duration = Config.Animations.medium
        let animationFrame = AnimationFrame.movingField(newBaseFieldOffset: baseFieldOffset, newSparePillarOffset: sparePillarOffset)
        return .init(duration: duration, delay: delay, animation: .linear(duration: duration), animationFrame: animationFrame)
    }
    
    static func preparePerfectHit(delay: CGFloat) -> KeyFrame {
        .init(duration: 0, delay: delay, animation: nil, animationFrame: .preparePerfectHit)
    }
    
    static func perfectHit(delay: CGFloat) -> KeyFrame {
        let duration = Config.Animations.long
        let animationFrame = AnimationFrame.perfectHit(bonusScale: Config.Bonus.maxScale, centerScale: Config.Pillar.Center.maxScale)
        return .init(duration: duration, delay: delay, animation: .linear(duration: duration), animationFrame: animationFrame)
    }
    
    static func targetCenterFading(delay: CGFloat) -> KeyFrame {
        let duration = Config.Animations.medium
        return .init(duration: duration, delay: delay, animation: .linear(duration: duration), animationFrame: .targetCenterFading)
    }
}

extension Array where Element == KeyFrame {
    /// finding the end time of animation that finishes last
    var endTime: Double {
        self.max(by: { $0.endTime < $1.endTime })?.endTime ?? 0.0
    }
}

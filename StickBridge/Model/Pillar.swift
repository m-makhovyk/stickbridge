import Foundation
import SwiftUI

struct Pillar {
    let startX: CGFloat
    let width: CGFloat
    let showCenter: Bool
    
    var centerX: CGFloat {
        startX + (width / 2)
    }
    
    var endX: CGFloat {
        startX + width
    }
}

extension Pillar {
    
    func didHit(bridgeEndX: CGFloat) -> Bool {
        /// we count as hit if ball is a bit outside of pillar - by one quater of ball size
        let safeDistance = Config.Ball.size / 4
        let successRange = startX - safeDistance...endX + safeDistance
        return successRange.contains(bridgeEndX)
    }
    
    func didHitCenter(x: CGFloat) -> Bool {
        let targetSize = Config.Pillar.Center.size
        let centerTargetStart = centerX - targetSize / 2
        let centerTargetEnd = centerX + targetSize / 2
        return (centerTargetStart...centerTargetEnd).contains(x)
    }
    
    static func generate(showCenter: Bool = true) -> Pillar {
        .init(startX: 0, width: 100, showCenter: showCenter)
    }
}

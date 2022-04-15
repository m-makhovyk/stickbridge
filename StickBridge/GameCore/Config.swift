import Foundation
import SwiftUI

struct Config {
    
    struct Ball {
        static let size: CGFloat = 20
        static var radius: CGFloat { size / 2 }
        static let backgroundColor = Color.black
        static let borderColor = Color.white
        static let borderWidth: CGFloat = 0.5
        /// points per 0.1s
        static let speed = 52.0
    }
    
    struct Pillar {
        static let height: CGFloat = 300
        static let color = Color("pillarBackground")
        
        struct Center {
            static let size: CGFloat = 15
            static let height: CGFloat = 5
            static let color = Color.red
            static let maxScale = 2.0
        }
    }
    
    struct Bridge {
        static let width: CGFloat = 3.5
        static let color = Color.black
        static let deltaPerTick: CGFloat = 5.0
        
        enum Angle: CGFloat {
            case vertical = 0
            case horizontal = 90
            case fallen = 170
        }
    }
    
    struct Bonus {
        static let title = NSLocalizedString("Perfect", comment: "")
        static let maxScale = 1.5
    }
    
    struct Animations {
        static let long = 0.7
        static let medium = 0.35
        static let short = 0.2
    }
}

import Foundation

func log(_ message: String, category: Logger.Category = .app) {
    Logger().log(message, category: category)
}

public class Logger {
    
    public enum Category {
        case app
        case pillarGenerator
        case gameCore
        case feedbackGenerator
        case custom(String)

        public var rawValue: String {
            switch self {
            case .app: return "APP"
            case .pillarGenerator: return "PILLAR GENERATOR"
            case .gameCore: return "GAME CORE"
            case .feedbackGenerator: return "FEEDBACK GENERATOR"
            case let .custom(customCategory): return customCategory.uppercased()
            }
        }
        
        public var emoji: String {
            switch self {
            case .app: return "📌"
            case .pillarGenerator: return "🎲"
            case .gameCore: return "💡"
            case .feedbackGenerator: return "🎵"
            default: return "💬"
            }
        }
    }
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:m:ss.SSS"
        return dateFormatter
    }()
    
    public static var enabled = true
    
    open func log(_ message: String, category: Category) {
        guard Logger.enabled else { return }
        
        print("\(category.emoji) [\(category.rawValue)] (\(dateFormatter.string(from: Date()))) \(message)")
    }
}

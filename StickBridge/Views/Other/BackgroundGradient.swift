import SwiftUI

enum GradientColor: String, CaseIterable, Equatable {
    case blue
    case green
    case orange
    case purple
    
    var light: Color {
        .init("\(rawValue)Light")
    }
    
    var dark: Color {
        .init("\(rawValue)Dark")
    }
}

struct GradientView: View {
    let gradient: GradientColor
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [gradient.light, gradient.dark]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

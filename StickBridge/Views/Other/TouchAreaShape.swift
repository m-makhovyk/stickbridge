import SwiftUI

struct TouchAreaShape: Shape {
    
    /// making bottom area untappable so when user swipes the app to background it does not affect the game
    /// making top area untappable so gestures don not conflict
    /// TODO find more intelligent way to handle this
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 100))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 100))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 80))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 80))

        return path
    }
}

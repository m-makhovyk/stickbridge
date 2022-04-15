import SwiftUI

// based on https://fivestars.blog/swiftui/conditional-modifiers.html
@available(iOS 13.0, *)
public extension View {
    @ViewBuilder
    func `if`<TrueContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
    
    @ViewBuilder
    func ifLet<V, Transform: View>(_ value: V?, transform: (Self, V) -> Transform) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

struct CrossedModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(
            Rectangle()
                .fill(Color.black)
                .frame(width: 1.5)
                .rotationEffect(.degrees(45)),
            alignment: .center
        )
    }
}

public extension View {
    func crossed() -> some View {
        modifier(CrossedModifier())
    }
    
    
}

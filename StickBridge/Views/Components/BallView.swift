import SwiftUI

struct BallView: View {
    let config = Config.Ball.self
    var body: some View {
        Circle()
            .strokeBorder(config.borderColor, lineWidth: config.borderWidth)
            .background(
                Circle()
                    .foregroundColor(config.backgroundColor)
            )
            .frame(width: config.size, height: config.size)
    }
}

struct BallView_Previews: PreviewProvider {
    static var previews: some View {
        BallView()
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}

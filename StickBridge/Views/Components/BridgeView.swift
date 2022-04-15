import Foundation
import SwiftUI

struct BridgeView: View {
    let config = Config.Bridge.self
    let height: CGFloat
    var body: some View {
        return VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black)
                .frame(width: config.width, height: height)
            Rectangle()
                .fill(Color.clear)
                .frame(height: height)
        }
        .frame(width: 4)
    }
}

struct BridgeView_Previews: PreviewProvider {
    static var previews: some View {
        BridgeView(height: 200)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}

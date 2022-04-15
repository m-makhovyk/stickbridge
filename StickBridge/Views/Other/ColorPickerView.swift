import SwiftUI

struct ColorPickerView: View {
    let color: Color
    
    var body: some View {
        Circle()
            .strokeBorder(Color.white, lineWidth: 1)
            .background(
                Circle()
                    .foregroundColor(color)
            )
            .frame(width: 32, height: 32)
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(color: .orange)
    }
}

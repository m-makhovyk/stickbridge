import SwiftUI

struct PillarView: View {
    let pillar: Pillar
    var bonus = 0
    let config = Config.Pillar.self
    
    var body: some View {
        Rectangle()
            .fill(config.color)
            .frame(width: pillar.width, height: config.height)
    }
}

struct PillarView_Previews: PreviewProvider {
    static var previews: some View {
        PillarView(pillar: Pillar.generate())
            .previewLayout(.sizeThatFits)
            .padding()
        
        PillarView(pillar: Pillar.generate(showCenter: false))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

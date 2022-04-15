import SwiftUI

struct PillarsView: View {
    let startPillar: Pillar
    let targetPillar: Pillar
    let sparePillar: Pillar
    
    let baseFieldOffset: CGFloat
    let sparePillarOffset: CGFloat
    let bonus: Int
    
    var body: some View {
        ZStack {
            Group {
                PillarView(pillar: startPillar)
                    .offset(x: -screenCenter + startPillar.centerX, y: 0)
                PillarView(pillar: targetPillar, bonus: bonus)
                    .offset(x: -screenCenter + targetPillar.centerX, y: 0)
            }
            .offset(x: baseFieldOffset)
            Group {
                PillarView(pillar: sparePillar)
                    .offset(x: -screenCenter + sparePillar.centerX, y: 0)
            }
            .frame(maxWidth: .infinity)
            .offset(x: sparePillarOffset)
        }
    }
}

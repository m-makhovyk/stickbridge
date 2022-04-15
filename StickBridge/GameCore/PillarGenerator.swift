import Foundation
import SwiftUI

typealias PillarsSet = (start: Pillar, target: Pillar, spare: Pillar)

class PillarGenerator {
    
    static let shared = PillarGenerator()
    
    private let widthRange = 30...100
    private let minSpacing = 15
    
    private var randomWidth: CGFloat {
        CGFloat(Int.random(in: widthRange))
    }
    
    func generateInitialPillars() -> PillarsSet {
        let startPillar = generateStartPillar(with: randomWidth)
        let targetPillar = generateTargetPillar(with: randomWidth, startPillarEndX: startPillar.endX)
        let sparePillar = generateSparePillar()
        log("shift:\nstart: \(startPillar),\ntarget: \(targetPillar),\nspare: \(sparePillar)", category: .pillarGenerator)
        return (startPillar, targetPillar, sparePillar)
    }
    
    func shiftPillars(_ pillars: PillarsSet) -> PillarsSet {
        let startPillar = generateStartPillar(with: pillars.target.width)
        let targetPillar = generateTargetPillar(with: pillars.spare.width, startPillarEndX: pillars.target.width)
        let sparePillar = generateSparePillar()
        log("shift:\nstart: \(startPillar),\ntarget: \(targetPillar),\nspare: \(sparePillar)", category: .pillarGenerator)
        return (startPillar, targetPillar, sparePillar)
    }
    
    /// the very first start pillar is created with random width, following ones take second pillar width
    private func generateStartPillar(with width: CGFloat) -> Pillar {
        Pillar(startX: 0, width: width, showCenter: false)
    }
    
    /// creates pillar in range from previous pillar end + spacing and to the screen width
    private func generateTargetPillar(with width: CGFloat, startPillarEndX: CGFloat) -> Pillar {
        let pillarStartX = CGFloat(Int.random(in: Int(startPillarEndX) + minSpacing...Int(screenWidth - width)))
        return Pillar(startX: pillarStartX, width: width, showCenter: true)
    }
    
    /// third pillar always starts right beyond the screen width
    private func generateSparePillar() -> Pillar {
        Pillar(startX: screenWidth, width: randomWidth, showCenter: true)
    }
}

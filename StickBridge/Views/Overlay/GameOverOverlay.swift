import SwiftUI

struct GameOverOverlay: View {
    let state: GameState
    let score: Int
    let completion: () -> ()
    
    @AppStorage(AppStorageKey.isSoundOn.rawValue) private var isSoundOn = true
    @AppStorage(AppStorageKey.isVibroOn.rawValue) private var isVibroOn = true
    
    var body: some View {
        ZStack {
            VStack {
                if state == .finished {
                    Text(NSLocalizedString("Your score:", comment: ""))
                        .font(.title2)
                    Text("\(score)")
                        .font(Font.system(size: 40))
                        .padding()
                }
                Image(systemName: state == .finished ? "arrow.clockwise" : "play")
                    .font(.system(size: 60))
                    .onTapGesture {
                        completion()
                    }
            }
            
            settings
                .offset(y: -screenHeight / 2 + UIConstants.settingsTopPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(Color.init(white: 0.8))
                .opacity(0.9)
        )
    }
    
    var settings: some View {
        HStack(spacing: 16) {
            Spacer()
            settingsImage("vibro", crossed: !isVibroOn) {
                isVibroOn.toggle()
                log("Vibro is enabled: \(isVibroOn)")
            }
            settingsImage("speaker", crossed: !isSoundOn) {
                isSoundOn.toggle()
                log("Sound is enabled: \(isVibroOn)")
            }
        }
        .padding(.horizontal)
        .padding(.top, UIConstants.settingsTopPadding)
    }
    
    @ViewBuilder
    func settingsImage(_ name: String, crossed: Bool, onTap: @escaping () -> ()) -> some View {
        Image(name)
            .resizable()
            .frame(width: UIConstants.settingsImageSize, height: UIConstants.settingsImageSize)
            .if(crossed) {
                $0.crossed()
            }
            .onTapGesture {
                onTap()
            }
    }
}

struct GameOverOverlay_Previews: PreviewProvider {
    static var previews: some View {
        GameOverOverlay(state: .finished, score: 12, completion: {})
    }
}

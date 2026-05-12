import SwiftUI

struct ContentView: View {
    @State private var selectedMode: GameMode?

    enum GameMode: String, CaseIterable {
        case explore = "🔢"
        case counting = "🐻"
        case math = "➕"

        var title: String {
            switch self {
            case .explore: return "Numbers"
            case .counting: return "Count"
            case .math: return "Add"
            }
        }

        var color: Color {
            switch self {
            case .explore: return .blue
            case .counting: return .green
            case .math: return .orange
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [.purple.opacity(0.3), .blue.opacity(0.3), .cyan.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    // Title with bouncing animation
                    Text("🎉 Number Fun! 🎉")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .white, radius: 2)

                    // Game mode buttons
                    HStack(spacing: 30) {
                        ForEach(GameMode.allCases, id: \.self) { mode in
                            NavigationLink(value: mode) {
                                GameModeButton(mode: mode)
                            }
                            .buttonStyle(BounceButtonStyle())
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
            .navigationDestination(for: GameMode.self) { mode in
                switch mode {
                case .explore:
                    NumberExploreView()
                case .counting:
                    CountingGameView()
                case .math:
                    MathGameView()
                }
            }
        }
    }
}

struct GameModeButton: View {
    let mode: ContentView.GameMode
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(mode.color.gradient)
                    .frame(width: 180, height: 180)
                    .shadow(color: mode.color.opacity(0.5), radius: 10, x: 0, y: 5)

                Text(mode.rawValue)
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }

            Text(mode.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}

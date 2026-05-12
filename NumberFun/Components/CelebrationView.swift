import SwiftUI

struct CelebrationView: View {
    @Binding var isShowing: Bool
    @State private var confetti: [ConfettiPiece] = []

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }

            // Celebration content
            VStack(spacing: 30) {
                // Stars burst
                ZStack {
                    ForEach(0..<12) { index in
                        Image(systemName: "star.fill")
                            .foregroundColor([.yellow, .orange, .pink, .cyan].randomElement()!)
                            .font(.system(size: 50))
                            .offset(
                                x: cos(Double(index) * .pi / 6) * 100,
                                y: sin(Double(index) * .pi / 6) * 100
                            )
                            .scaleEffect(isShowing ? 1 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.6)
                                .delay(Double(index) * 0.05),
                                value: isShowing
                            )
                    }

                    Text("🎉")
                        .font(.system(size: 120))
                        .scaleEffect(isShowing ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5), value: isShowing)
                }

                Text("Great Job!")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .orange, radius: 10)
                    .scaleEffect(isShowing ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2), value: isShowing)
            }

            // Confetti
            ForEach(confetti) { piece in
                ConfettiView(piece: piece)
            }
        }
        .onAppear {
            generateConfetti()
            // Auto dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }

    private func generateConfetti() {
        confetti = (0..<50).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                color: [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan].randomElement()!,
                size: CGFloat.random(in: 10...20),
                delay: Double.random(in: 0...0.5)
            )
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let color: Color
    let size: CGFloat
    let delay: Double
}

struct ConfettiView: View {
    let piece: ConfettiPiece
    @State private var animate = false

    var body: some View {
        Circle()
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size)
            .position(x: piece.x, y: animate ? UIScreen.main.bounds.height + 50 : -50)
            .rotationEffect(.degrees(animate ? 360 : 0))
            .onAppear {
                withAnimation(
                    .easeIn(duration: Double.random(in: 1.5...2.5))
                    .delay(piece.delay)
                ) {
                    animate = true
                }
            }
    }
}

struct MiniCelebration: View {
    @State private var stars: [(offset: CGSize, rotation: Double)] = []
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor([.yellow, .orange, .pink].randomElement()!)
                    .font(.system(size: 30))
                    .offset(
                        x: animate ? CGFloat.random(in: -80...80) : 0,
                        y: animate ? CGFloat.random(in: -80...80) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 1.5 : 0.5)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animate = true
            }
        }
    }
}

#Preview {
    CelebrationView(isShowing: .constant(true))
}

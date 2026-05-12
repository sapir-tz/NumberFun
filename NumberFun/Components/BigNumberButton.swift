import SwiftUI

struct BigNumberButton: View {
    let number: Int
    let color: Color
    let action: () -> Void

    @State private var isPressed = false
    @State private var showStars = false

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan, .mint, .indigo]

    var buttonColor: Color {
        colors[(number - 1) % colors.count]
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
                showStars = true
            }
            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    isPressed = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showStars = false
            }
        }) {
            ZStack {
                // Button background
                RoundedRectangle(cornerRadius: 25)
                    .fill(buttonColor.gradient)
                    .frame(width: 140, height: 140)
                    .shadow(color: buttonColor.opacity(0.5), radius: isPressed ? 15 : 8, x: 0, y: isPressed ? 2 : 5)

                // Number text
                Text("\(number)")
                    .font(.system(size: 70, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)

                // Stars animation
                if showStars {
                    StarBurst()
                }
            }
            .scaleEffect(isPressed ? 1.2 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StarBurst: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 25))
                    .offset(
                        x: animate ? CGFloat.random(in: -60...60) : 0,
                        y: animate ? CGFloat.random(in: -60...60) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animate = true
            }
        }
    }
}

#Preview {
    BigNumberButton(number: 5, color: .blue) {
        print("Tapped 5")
    }
}

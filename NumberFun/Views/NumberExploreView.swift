import SwiftUI

struct NumberExploreView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var soundManager = SoundManager.shared
    @State private var selectedNumber: Int?
    @State private var showingObjects = false

    private let numbers = Array(1...10)
    private let objects = ["⭐", "🌟", "✨", "💫", "🎈", "🎀", "🌈", "🦋", "🐝", "🌸"]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Back button and title
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Circle().fill(Color.purple.gradient))
                            .shadow(color: .purple.opacity(0.5), radius: 5)
                    }

                    Spacer()

                    Text("Tap a Number!")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)

                    Spacer()

                    // Spacer for balance
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 80, height: 80)
                }
                .padding(.horizontal, 30)

                // Selected number display area
                if let selected = selectedNumber {
                    NumberDisplayView(number: selected, showingObjects: showingObjects)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("👆")
                        .font(.system(size: 100))
                        .opacity(0.5)
                        .frame(height: 200)
                }

                Spacer()

                // Number grid
                NumberGridView(
                    selectedNumber: $selectedNumber,
                    showingObjects: $showingObjects,
                    soundManager: soundManager
                )

                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

struct NumberDisplayView: View {
    let number: Int
    let showingObjects: Bool

    @State private var animateNumber = false
    @State private var showStars = false

    private let objects = ["⭐", "🌟", "💫", "✨", "🎈", "🎀", "🦋", "🌸", "🐝", "🌺"]

    var body: some View {
        VStack(spacing: 20) {
            // Large animated number
            Text("\(number)")
                .font(.system(size: 150, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.5), radius: 10)
                .scaleEffect(animateNumber ? 1.1 : 1.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        animateNumber = true
                    }
                }

            // Objects representing the number
            if showingObjects {
                HStack(spacing: 15) {
                    ForEach(0..<number, id: \.self) { index in
                        Text(objects[number - 1])
                            .font(.system(size: 50))
                            .scaleEffect(showStars ? 1.0 : 0.0)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.6)
                                .delay(Double(index) * 0.1),
                                value: showStars
                            )
                    }
                }
                .onAppear {
                    showStars = true
                }
            }
        }
        .frame(height: 250)
        .id(number) // Force view refresh when number changes
        .onAppear {
            showStars = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showStars = true
            }
        }
    }
}

struct NumberGridView: View {
    @Binding var selectedNumber: Int?
    @Binding var showingObjects: Bool
    let soundManager: SoundManager

    private let numbers = Array(1...10)
    private let colors: [Color] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .mint, .indigo]

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 20
        ) {
            ForEach(numbers, id: \.self) { number in
                NumberTile(
                    number: number,
                    color: colors[number - 1],
                    isSelected: selectedNumber == number
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedNumber = number
                        showingObjects = true
                    }
                    soundManager.speakNumber(number)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct NumberTile: View {
    let number: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.gradient)
                    .frame(width: 120, height: 120)
                    .shadow(
                        color: color.opacity(isSelected ? 0.8 : 0.4),
                        radius: isSelected ? 15 : 8,
                        x: 0,
                        y: isSelected ? 2 : 5
                    )

                Text("\(number)")
                    .font(.system(size: 55, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
            .scaleEffect(isPressed ? 1.15 : (isSelected ? 1.05 : 1.0))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: isSelected ? 4 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NumberExploreView()
}

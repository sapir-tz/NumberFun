import SwiftUI

struct MathGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var soundManager = SoundManager.shared

    @State private var firstNumber = 1
    @State private var secondNumber = 1
    @State private var correctAnswer = 2
    @State private var options: [Int] = []
    @State private var currentObject: ObjectCountView.ObjectType = .apple
    @State private var showCelebration = false
    @State private var wrongAnswer: Int?
    @State private var score = 0
    @State private var showEquation = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.orange.opacity(0.3), .pink.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Circle().fill(Color.orange.gradient))
                            .shadow(color: .orange.opacity(0.5), radius: 5)
                    }

                    Spacer()

                    // Score display
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 30))
                        Text("\(score)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                            .shadow(radius: 5)
                    )

                    Spacer()

                    // New problem button
                    Button(action: { generateNewProblem() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Circle().fill(Color.pink.gradient))
                            .shadow(color: .pink.opacity(0.5), radius: 5)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()

                // Visual equation
                if showEquation {
                    VisualEquationView(
                        firstNumber: firstNumber,
                        secondNumber: secondNumber,
                        objectType: currentObject
                    )
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Text equation
                HStack(spacing: 15) {
                    Text("\(firstNumber)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Text("+")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.pink)

                    Text("\(secondNumber)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)

                    Text("=")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.gray)

                    Text("?")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.8))
                        .shadow(radius: 10)
                )

                Spacer()

                // Answer buttons
                HStack(spacing: 30) {
                    ForEach(options, id: \.self) { option in
                        MathAnswerButton(
                            number: option,
                            isWrong: wrongAnswer == option
                        ) {
                            checkAnswer(option)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .padding()

            // Celebration overlay
            if showCelebration {
                CelebrationView(isShowing: $showCelebration)
                    .onDisappear {
                        generateNewProblem()
                    }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            generateNewProblem()
        }
    }

    private func generateNewProblem() {
        // Reset states
        wrongAnswer = nil
        showCelebration = false
        showEquation = false

        // Generate simple addition (sums up to 5 for toddlers)
        firstNumber = Int.random(in: 1...3)
        secondNumber = Int.random(in: 1...(5 - firstNumber))
        correctAnswer = firstNumber + secondNumber

        // Generate wrong options
        var wrongOptions = Set<Int>()
        while wrongOptions.count < 2 {
            let wrong = Int.random(in: max(1, correctAnswer - 2)...min(6, correctAnswer + 2))
            if wrong != correctAnswer && wrong > 0 {
                wrongOptions.insert(wrong)
            }
        }

        // Shuffle options
        options = ([correctAnswer] + Array(wrongOptions)).shuffled()

        // Random object
        currentObject = ObjectCountView.ObjectType.allCases.randomElement() ?? .apple

        // Animate in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
            showEquation = true
        }
    }

    private func checkAnswer(_ answer: Int) {
        if answer == correctAnswer {
            // Correct!
            score += 1
            soundManager.playCorrectSound()
            withAnimation {
                showCelebration = true
            }
        } else {
            // Wrong - gentle feedback
            withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                wrongAnswer = answer
            }
            soundManager.playTryAgainSound()

            // Reset wrong indicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    wrongAnswer = nil
                }
            }
        }
    }
}

struct VisualEquationView: View {
    let firstNumber: Int
    let secondNumber: Int
    let objectType: ObjectCountView.ObjectType

    @State private var animateFirst = false
    @State private var animateSecond = false

    var body: some View {
        HStack(spacing: 30) {
            // First group of objects
            HStack(spacing: 10) {
                ForEach(0..<firstNumber, id: \.self) { index in
                    Text(objectType.emoji)
                        .font(.system(size: 55))
                        .scaleEffect(animateFirst ? 1.0 : 0.0)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.6)
                            .delay(Double(index) * 0.1),
                            value: animateFirst
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.orange.opacity(0.2))
            )

            // Plus sign
            Text("+")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.pink)

            // Second group of objects
            HStack(spacing: 10) {
                ForEach(0..<secondNumber, id: \.self) { index in
                    Text(objectType.emoji)
                        .font(.system(size: 55))
                        .scaleEffect(animateSecond ? 1.0 : 0.0)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.6)
                            .delay(0.3 + Double(index) * 0.1),
                            value: animateSecond
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.purple.opacity(0.2))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 10)
        )
        .onAppear {
            animateFirst = true
            animateSecond = true
        }
    }
}

struct MathAnswerButton: View {
    let number: Int
    let isWrong: Bool
    let action: () -> Void

    @State private var isPressed = false

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [colors[number % colors.count], colors[(number + 1) % colors.count]],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 130, height: 130)
                    .shadow(
                        color: isWrong ? .red.opacity(0.8) : colors[number % colors.count].opacity(0.5),
                        radius: isWrong ? 15 : 10
                    )

                Text("\(number)")
                    .font(.system(size: 65, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
            .scaleEffect(isPressed ? 1.1 : 1.0)
            .scaleEffect(isWrong ? 0.9 : 1.0)
            .rotationEffect(.degrees(isWrong ? -5 : 0))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isWrong ? Color.red : Color.clear, lineWidth: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MathGameView()
}

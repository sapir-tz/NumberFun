import SwiftUI

struct CountingGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var soundManager = SoundManager.shared

    @State private var correctAnswer = 1
    @State private var options: [Int] = []
    @State private var currentAnimal: AnimalCountView.AnimalType = .bear
    @State private var showCelebration = false
    @State private var wrongAnswer: Int?
    @State private var score = 0
    @State private var questionsAsked = 0

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.green.opacity(0.3), .yellow.opacity(0.3), .orange.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Circle().fill(Color.green.gradient))
                            .shadow(color: .green.opacity(0.5), radius: 5)
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

                    // New game button
                    Button(action: { generateNewQuestion() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Circle().fill(Color.orange.gradient))
                            .shadow(color: .orange.opacity(0.5), radius: 5)
                    }
                }
                .padding(.horizontal, 30)

                // Question prompt
                Text("How many \(currentAnimal.emoji)?")
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                // Animals to count
                AnimalCountView(count: correctAnswer, animalType: currentAnimal)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white.opacity(0.7))
                            .shadow(radius: 10)
                    )
                    .padding(.horizontal, 40)

                Spacer()

                // Answer buttons
                HStack(spacing: 30) {
                    ForEach(options, id: \.self) { option in
                        AnswerButton(
                            number: option,
                            isCorrect: option == correctAnswer,
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
                        generateNewQuestion()
                    }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            generateNewQuestion()
        }
    }

    private func generateNewQuestion() {
        // Reset states
        wrongAnswer = nil
        showCelebration = false

        // Generate new question (1-5 for toddlers)
        correctAnswer = Int.random(in: 1...5)

        // Generate wrong options
        var wrongOptions = Set<Int>()
        while wrongOptions.count < 2 {
            let wrong = Int.random(in: 1...5)
            if wrong != correctAnswer {
                wrongOptions.insert(wrong)
            }
        }

        // Shuffle options
        options = ([correctAnswer] + Array(wrongOptions)).shuffled()

        // Random animal
        currentAnimal = AnimalCountView.AnimalType.allCases.randomElement() ?? .bear
    }

    private func checkAnswer(_ answer: Int) {
        if answer == correctAnswer {
            // Correct!
            score += 1
            questionsAsked += 1
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

            // Reset wrong indicator after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    wrongAnswer = nil
                }
            }
        }
    }
}

struct AnswerButton: View {
    let number: Int
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void

    @State private var isPressed = false

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan, .mint, .indigo]

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
                Circle()
                    .fill(colors[number - 1].gradient)
                    .frame(width: 140, height: 140)
                    .shadow(
                        color: isWrong ? .red.opacity(0.8) : colors[number - 1].opacity(0.5),
                        radius: isWrong ? 15 : 10
                    )

                Text("\(number)")
                    .font(.system(size: 70, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
            .scaleEffect(isPressed ? 1.1 : 1.0)
            .scaleEffect(isWrong ? 0.9 : 1.0)
            .rotationEffect(.degrees(isWrong ? -5 : 0))
            .overlay(
                Circle()
                    .stroke(isWrong ? Color.red : Color.clear, lineWidth: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CountingGameView()
}

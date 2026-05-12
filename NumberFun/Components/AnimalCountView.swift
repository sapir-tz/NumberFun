import SwiftUI

struct AnimalCountView: View {
    let count: Int
    let animalType: AnimalType

    enum AnimalType: CaseIterable {
        case bear, cat, dog, rabbit, frog, bird, fish, butterfly

        var emoji: String {
            switch self {
            case .bear: return "🐻"
            case .cat: return "🐱"
            case .dog: return "🐶"
            case .rabbit: return "🐰"
            case .frog: return "🐸"
            case .bird: return "🐦"
            case .fish: return "🐟"
            case .butterfly: return "🦋"
            }
        }
    }

    @State private var animatedIndices: Set<Int> = []

    var body: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(0..<count, id: \.self) { index in
                Text(animalType.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(animatedIndices.contains(index) ? 1.0 : 0.5)
                    .opacity(animatedIndices.contains(index) ? 1.0 : 0.0)
                    .onAppear {
                        withAnimation(
                            .spring(response: 0.5, dampingFraction: 0.6)
                            .delay(Double(index) * 0.15)
                        ) {
                            animatedIndices.insert(index)
                        }
                    }
            }
        }
        .padding()
    }
}

struct ObjectCountView: View {
    let count: Int
    let objectType: ObjectType

    enum ObjectType: CaseIterable {
        case apple, star, heart, ball, flower, sun, moon, cookie

        var emoji: String {
            switch self {
            case .apple: return "🍎"
            case .star: return "⭐"
            case .heart: return "❤️"
            case .ball: return "🏀"
            case .flower: return "🌸"
            case .sun: return "☀️"
            case .moon: return "🌙"
            case .cookie: return "🍪"
            }
        }
    }

    @State private var animatedIndices: Set<Int> = []

    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<count, id: \.self) { index in
                Text(objectType.emoji)
                    .font(.system(size: 60))
                    .scaleEffect(animatedIndices.contains(index) ? 1.0 : 0.5)
                    .opacity(animatedIndices.contains(index) ? 1.0 : 0.0)
                    .onAppear {
                        withAnimation(
                            .spring(response: 0.5, dampingFraction: 0.6)
                            .delay(Double(index) * 0.2)
                        ) {
                            animatedIndices.insert(index)
                        }
                    }
            }
        }
        .padding()
    }
}

#Preview {
    VStack {
        AnimalCountView(count: 5, animalType: .bear)
        ObjectCountView(count: 3, objectType: .apple)
    }
}

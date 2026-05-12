import AVFoundation
import SwiftUI

class SoundManager: ObservableObject {
    static let shared = SoundManager()

    private let synthesizer = AVSpeechSynthesizer()

    private let numberWords = [
        1: "One",
        2: "Two",
        3: "Three",
        4: "Four",
        5: "Five",
        6: "Six",
        7: "Seven",
        8: "Eight",
        9: "Nine",
        10: "Ten"
    ]

    private let encouragements = [
        "Great job!",
        "Wonderful!",
        "You did it!",
        "Amazing!",
        "Super!",
        "Yay!"
    ]

    init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    func speakNumber(_ number: Int) {
        guard let word = numberWords[number] else { return }
        speak(word)
    }

    func speakEncouragement() {
        let encouragement = encouragements.randomElement() ?? "Great!"
        speak(encouragement)
    }

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.4 // Slower for toddlers
        utterance.pitchMultiplier = 1.2 // Slightly higher, friendlier pitch
        utterance.volume = 1.0

        // Use a friendly voice
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }

        synthesizer.speak(utterance)
    }

    func playCorrectSound() {
        speakEncouragement()
    }

    func playTryAgainSound() {
        speak("Try again!")
    }
}

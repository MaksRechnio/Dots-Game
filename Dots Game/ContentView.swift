import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var score = 0
    @State private var dots: [Dot] = []
    @State private var timeRemaining = 60
    @State private var gameActive = false
    @State private var timer: Timer?
    @State private var clickSoundPlayer: AVAudioPlayer? //for the clickedDot sound
    @State private var countdownSoundPlayer: AVAudioPlayer? // for the countdown
    @State private var highScore = 0    //preset highscore for everyone
    @State private var countdown = 5
    @State private var isCountingDown = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // Dots
            ForEach(dots) { dot in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 70, height: 70)
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 4)
                    .position(dot.position)
                    .onTapGesture {
                        if gameActive {
                            score += 1
                            remove(dot)
                            spawnDot()
                            clickSoundPlayer?.currentTime = 0
                            clickSoundPlayer?.play()
                        }
                    }
            }

            VStack {
                HStack {
                    Text("High Score: \(highScore)")
                        .foregroundColor(.black)
                    Spacer()
                }
                HStack {
                    Text("Score: \(score)")
                        .foregroundColor(.black)
                    Spacer()
                    Text("Time: \(timeRemaining)")
                        .foregroundColor(.black)
                }
                .padding()
                
                Spacer()
                
                if !gameActive && !isCountingDown {
                    Button("Start Game") {
                        startCountdown()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
            .padding()

            // Countdown Overlay
            if isCountingDown {
                Text("\(countdown)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.black)
                    .transition(.scale)
            }
        }
        .onAppear {
            spawnInitialDots(count: 4)
            loadSounds()
        }
    }


    func startCountdown() {
        score = 0
        timeRemaining = 45
        countdown = 5
        isCountingDown = true
        gameActive = false
        spawnInitialDots(count: 5)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdownSoundPlayer?.currentTime = 0  // 🔁 Restart from beginning
            countdownSoundPlayer?.play()           // ▶️ Play from start

            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                isCountingDown = false
                gameActive = true
                startGameTimer()
            }
        }
    }
    

    func startGameTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameActive = false
                timer?.invalidate()
                if score > highScore {
                    highScore = score
                }
            }
        }
    }

    // MARK: - Dot Logic

    func spawnDot() {
        let maxAttempts = 30
        var attempts = 0
        var newDot: Dot?

        while attempts < maxAttempts {
            let x = CGFloat.random(in: 40...(UIScreen.main.bounds.width - 40))
            let y = CGFloat.random(in: 100...(UIScreen.main.bounds.height - 100))
            let position = CGPoint(x: x, y: y)
            
            let isTooClose = dots.contains { existingDot in
                let distance = hypot(existingDot.position.x - position.x, existingDot.position.y - position.y)
                return distance < 80
            }
            
            if !isTooClose {
                newDot = Dot(position: position)
                break
            }

            attempts += 1
        }

        if let validDot = newDot {
            dots.append(validDot)
        } else {
            print("Failed to place dot after \(maxAttempts) attempts")
        }
    }

    func spawnInitialDots(count: Int) {
        dots = []
        for _ in 0..<count {
            spawnDot()
        }
    }

    func remove(_ dot: Dot) {
        dots.removeAll { $0.id == dot.id }
    }

    func loadSounds() { //remade the function to account for the countdown sound as well and possible other ones in the future.
        // Click sound
        if let clickURL = Bundle.main.url(forResource: "click", withExtension: "mp3") {
            do {
                clickSoundPlayer = try AVAudioPlayer(contentsOf: clickURL)
                clickSoundPlayer?.prepareToPlay()
            } catch {
                print("Error loading click sound: \(error.localizedDescription)")
            }
        }
        
        // Countdown sound
        if let countdownURL = Bundle.main.url(forResource: "countdown", withExtension: "mp3") {
            do {
                countdownSoundPlayer = try AVAudioPlayer(contentsOf: countdownURL)
                countdownSoundPlayer?.prepareToPlay()
            } catch {
                print("Error loading countdown sound: \(error.localizedDescription)")
            }
        }
    }
}

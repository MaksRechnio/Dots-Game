import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var score = 0
    @State private var dots: [Dot] = []
    @State private var timeRemaining = 60
    @State private var gameActive = false
    @State private var timer: Timer?
    @State private var clickSoundPlayer: AVAudioPlayer? // 👈 THIS IS NEEDED
    @State private var highScore = 0
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // Kropki
            ForEach(dots) { dot in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 70, height: 70) //Changed the dot for a bigger one for better experience
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
                
                if !gameActive {
                    Button("Start Game") {
                        startGame()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
            .padding()
        }
        .onAppear {
            spawnInitialDots(count: 4)
            loadClickSound()
        }
    }

    func startGame() {
        score = 0
        timeRemaining = 45 //changed for 45 seconds and one minute is quite long
        gameActive = true
        spawnInitialDots(count: 5)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameActive = false
                timer?.invalidate()
            }
            // ✅ Update high score
                if score > highScore {
                    highScore = score
                }
        }
    }

    func spawnDot() {
        let x = CGFloat.random(in: 40...(UIScreen.main.bounds.width - 40))
        let y = CGFloat.random(in: 100...(UIScreen.main.bounds.height - 100))
        dots.append(Dot(position: CGPoint(x: x, y: y)))
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
    
    // ✅ Move this function inside the struct
        func loadClickSound() {
            if let soundURL = Bundle.main.url(forResource: "click", withExtension: "mp3") {
                do {
                    clickSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    clickSoundPlayer?.prepareToPlay()
                } catch {
                    print("Error loading sound: \(error.localizedDescription)")
                }
            }
        }
}


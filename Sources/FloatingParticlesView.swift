import SwiftUI

struct FloatingParticlesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var particles: [FloatingParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .blur(radius: particle.blur)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                startFloating(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateParticles(in size: CGSize) {
        var newParticles: [FloatingParticle] = []
        
        for _ in 0..<15 {
            newParticles.append(FloatingParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 2...4),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan].randomElement()!.opacity(0.3),
                opacity: Double.random(in: 0.2...0.5),
                blur: CGFloat.random(in: 0.5...1.5),
                velocity: CGPoint(
                    x: CGFloat.random(in: -0.5...0.5),
                    y: CGFloat.random(in: -0.8...0.8)
                )
            ))
        }
        
        particles = newParticles
    }
    
    private func startFloating(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for index in particles.indices {
                var particle = particles[index]
                
                particle.position.x += particle.velocity.x
                particle.position.y += particle.velocity.y
                
                if particle.position.x < -10 {
                    particle.position.x = size.width + 10
                } else if particle.position.x > size.width + 10 {
                    particle.position.x = -10
                }
                
                if particle.position.y < -10 {
                    particle.position.y = size.height + 10
                } else if particle.position.y > size.height + 10 {
                    particle.position.y = -10
                }
                
                particles[index] = particle
            }
        }
    }
}

struct FloatingParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
    var blur: CGFloat
    var velocity: CGPoint
}
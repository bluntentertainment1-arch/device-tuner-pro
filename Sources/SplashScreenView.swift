import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isAnimating = false
    @State private var navigateToMain = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var particlesOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var glowIntensity: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Group {
            if navigateToMain {
                MainDashboardView()
            } else {
                splashContent
            }
        }
    }
    
    private var splashContent: some View {
        ZStack {
            LinearGradient(
                colors: [
                    themeManager.background,
                    themeManager.accentColor.opacity(0.1),
                    themeManager.electricPink.opacity(0.1),
                    themeManager.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(rotationAngle))
            
            AnimatedParticlesView()
                .opacity(particlesOpacity)
            
            RadialGradient(
                colors: [
                    themeManager.accentColor.opacity(glowIntensity * 0.3),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        themeManager.electricPink.opacity(0.3),
                                        themeManager.electricCyan.opacity(0.3),
                                        themeManager.neonGreen.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 180 + CGFloat(index * 30), height: 180 + CGFloat(index * 30))
                            .opacity(glowIntensity * 0.4)
                            .scaleEffect(pulseScale + CGFloat(index) * 0.1)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        themeManager.accentColor,
                                        themeManager.electricPink,
                                        themeManager.neonPurple
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 160, height: 160)
                            .shadow(color: themeManager.accentColor.opacity(glowIntensity), radius: 40, x: 0, y: 0)
                            .shadow(color: themeManager.electricPink.opacity(glowIntensity * 0.8), radius: 60, x: 0, y: 0)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, themeManager.electricCyan],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(rotationAngle * 0.5))
                            .shadow(color: .white.opacity(0.8), radius: 10, x: 0, y: 0)
                        
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .offset(x: 20, y: -20)
                            .rotationEffect(.degrees(-rotationAngle * 0.3))
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                }
                .padding(.bottom, 40)
                
                VStack(spacing: 8) {
                    Text("Device Tuner PRO 26")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    themeManager.accentColor,
                                    themeManager.electricPink,
                                    themeManager.electricCyan
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: themeManager.accentColor.opacity(glowIntensity * 0.8), radius: 20, x: 0, y: 0)
                        .shadow(color: themeManager.electricPink.opacity(glowIntensity * 0.6), radius: 30, x: 0, y: 0)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.neonGreen)
                            .scaleEffect(pulseScale)
                        
                        Text("Manage Your Device")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        themeManager.primaryText,
                                        themeManager.accentColor.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.neonGreen)
                            .scaleEffect(pulseScale)
                    }
                    .shadow(color: themeManager.neonGreen.opacity(glowIntensity * 0.6), radius: 15, x: 0, y: 0)
                }
                .opacity(textOpacity)
                
                Spacer()
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(themeManager.borderColor.opacity(0.3), lineWidth: 3)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        themeManager.accentColor,
                                        themeManager.electricPink,
                                        themeManager.electricCyan
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(rotationAngle))
                            .shadow(color: themeManager.accentColor.opacity(0.6), radius: 8, x: 0, y: 0)
                    }
                    
                    Text("Loading...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(themeManager.secondaryText)
                }
                .opacity(textOpacity)
                .padding(.bottom, 60)
            }
            
            FloatingSparklesView()
                .opacity(particlesOpacity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        themeManager.updateTheme()
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.5).delay(0.2)) {
            glowIntensity = 1.0
        }
        
        withAnimation(.easeIn(duration: 1.0).delay(0.3)) {
            particlesOpacity = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.8).delay(0.5)) {
            textOpacity = 1.0
        }
        
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                navigateToMain = true
            }
        }
    }
}

struct AnimatedParticlesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var particles: [Particle] = []
    
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
                animateParticles()
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<30).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 2...6),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan, themeManager.neonGreen].randomElement()!,
                opacity: Double.random(in: 0.2...0.6),
                blur: CGFloat.random(in: 1...3)
            )
        }
    }
    
    private func animateParticles() {
        for index in particles.indices {
            let delay = Double.random(in: 0...2)
            let duration = Double.random(in: 2...4)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    particles[index].opacity = Double.random(in: 0.1...0.8)
                }
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
    var blur: CGFloat
}

struct FloatingSparklesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var sparkles: [FloatingSparkle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sparkles) { sparkle in
                    Image(systemName: "sparkle")
                        .font(.system(size: sparkle.size))
                        .foregroundColor(sparkle.color)
                        .position(sparkle.position)
                        .opacity(sparkle.opacity)
                        .rotationEffect(.degrees(sparkle.rotation))
                        .shadow(color: sparkle.color.opacity(0.8), radius: 8, x: 0, y: 0)
                }
            }
            .onAppear {
                generateSparkles(in: geometry.size)
                animateSparkles(in: geometry.size)
            }
        }
    }
    
    private func generateSparkles(in size: CGSize) {
        sparkles = (0..<15).map { _ in
            FloatingSparkle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 12...24),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan, themeManager.neonGreen].randomElement()!,
                opacity: Double.random(in: 0.3...0.7),
                rotation: Double.random(in: 0...360)
            )
        }
    }
    
    private func animateSparkles(in size: CGSize) {
        for index in sparkles.indices {
            let delay = Double.random(in: 0...1.5)
            let duration = Double.random(in: 2...4)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    sparkles[index].position.y += CGFloat.random(in: -50...50)
                    sparkles[index].opacity = Double.random(in: 0.2...0.9)
                    sparkles[index].rotation += Double.random(in: -180...180)
                }
            }
        }
    }
}

struct FloatingSparkle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
    var rotation: Double
}
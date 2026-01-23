import SwiftUI

struct SparklingStarsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animatingStars: [StarData] = []
    @State private var shootingStars: [ShootingStar] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(animatingStars) { star in
                    StarShape()
                        .fill(star.color)
                        .frame(width: star.size, height: star.size)
                        .position(star.position)
                        .opacity(star.opacity)
                        .rotationEffect(.degrees(star.rotation))
                        .scaleEffect(star.scale)
                        .blur(radius: star.blur)
                        .shadow(color: star.color.opacity(0.8), radius: star.glowRadius, x: 0, y: 0)
                }
                
                ForEach(shootingStars) { shootingStar in
                    ShootingStarView(star: shootingStar)
                }
            }
            .onAppear {
                generateStars(in: geometry.size)
                startTwinkling()
                startShootingStars(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateStars(in size: CGSize) {
        var stars: [StarData] = []
        
        // Top-left corner stars
        for _ in 0..<12 {
            stars.append(StarData(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width * 0.2),
                    y: CGFloat.random(in: 0...size.height * 0.2)
                ),
                size: CGFloat.random(in: 4...10),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan, themeManager.neonGreen].randomElement()!,
                opacity: Double.random(in: 0.4...1.0),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.6...1.2),
                blur: CGFloat.random(in: 0...2),
                glowRadius: CGFloat.random(in: 4...12)
            ))
        }
        
        // Top-right corner stars
        for _ in 0..<12 {
            stars.append(StarData(
                position: CGPoint(
                    x: CGFloat.random(in: size.width * 0.8...size.width),
                    y: CGFloat.random(in: 0...size.height * 0.2)
                ),
                size: CGFloat.random(in: 4...10),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan, themeManager.neonGreen].randomElement()!,
                opacity: Double.random(in: 0.4...1.0),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.6...1.2),
                blur: CGFloat.random(in: 0...2),
                glowRadius: CGFloat.random(in: 4...12)
            ))
        }
        
        // Bottom-left corner stars
        for _ in 0..<12 {
            stars.append(StarData(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width * 0.2),
                    y: CGFloat.random(in: size.height * 0.8...size.height)
                ),
                size: CGFloat.random(in: 4...10),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan, themeManager.neonGreen].randomElement()!,
                opacity: Double.random(in: 0.4...1.0),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.6...1.2),
                blur: CGFloat.random(in: 0...2),
                glowRadius: CGFloat.random(in: 4...12)
            ))
        }
        
        // Bottom-right corner stars
        for _ in 0..<12 {
            stars.append(StarData(
                position: CGPoint(
                    x: CGFloat.random(in: size.width * 0.8...size.width),
                    y: CGFloat.random(in: size.height * 0.8...size.height)
                ),
                size: CGFloat.random(in: 4...10),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan, themeManager.neonGreen].randomElement()!,
                opacity: Double.random(in: 0.4...1.0),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.6...1.2),
                blur: CGFloat.random(in: 0...2),
                glowRadius: CGFloat.random(in: 4...12)
            ))
        }
        
        // Scattered stars along edges
        for _ in 0..<20 {
            let edge = Int.random(in: 0...3)
            var position: CGPoint
            
            switch edge {
            case 0: // Top edge
                position = CGPoint(
                    x: CGFloat.random(in: size.width * 0.25...size.width * 0.75),
                    y: CGFloat.random(in: 0...size.height * 0.15)
                )
            case 1: // Right edge
                position = CGPoint(
                    x: CGFloat.random(in: size.width * 0.85...size.width),
                    y: CGFloat.random(in: size.height * 0.25...size.height * 0.75)
                )
            case 2: // Bottom edge
                position = CGPoint(
                    x: CGFloat.random(in: size.width * 0.25...size.width * 0.75),
                    y: CGFloat.random(in: size.height * 0.85...size.height)
                )
            default: // Left edge
                position = CGPoint(
                    x: CGFloat.random(in: 0...size.width * 0.15),
                    y: CGFloat.random(in: size.height * 0.25...size.height * 0.75)
                )
            }
            
            stars.append(StarData(
                position: position,
                size: CGFloat.random(in: 3...8),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan, themeManager.neonGreen].randomElement()!,
                opacity: Double.random(in: 0.3...1.0),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.5...1.0),
                blur: CGFloat.random(in: 0...2),
                glowRadius: CGFloat.random(in: 3...10)
            ))
        }
        
        animatingStars = stars
    }
    
    private func startTwinkling() {
        for index in animatingStars.indices {
            let delay = Double.random(in: 0...3)
            let duration = Double.random(in: 0.8...2.5)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    animatingStars[index].opacity = Double.random(in: 0.2...1.0)
                    animatingStars[index].scale = Double.random(in: 0.4...1.4)
                    animatingStars[index].rotation += Double.random(in: -180...180)
                    animatingStars[index].glowRadius = CGFloat.random(in: 2...15)
                }
            }
        }
    }
    
    private func startShootingStars(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            let newStar = ShootingStar(
                startPosition: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height * 0.3)
                ),
                endPosition: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: size.height
                ),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan].randomElement()!,
                duration: Double.random(in: 1.5...3.0)
            )
            
            withAnimation(.linear(duration: newStar.duration)) {
                shootingStars.append(newStar)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + newStar.duration) {
                shootingStars.removeAll { $0.id == newStar.id }
            }
        }
    }
}

struct ShootingStarView: View {
    let star: ShootingStar
    @State private var progress: CGFloat = 0
    
    var body: some View {
        Path { path in
            let currentX = star.startPosition.x + (star.endPosition.x - star.startPosition.x) * progress
            let currentY = star.startPosition.y + (star.endPosition.y - star.startPosition.y) * progress
            
            path.move(to: CGPoint(x: currentX, y: currentY))
            path.addLine(to: CGPoint(
                x: currentX - 30,
                y: currentY - 30
            ))
        }
        .stroke(star.color, lineWidth: 2)
        .blur(radius: 1)
        .shadow(color: star.color.opacity(0.8), radius: 8, x: 0, y: 0)
        .onAppear {
            withAnimation(.linear(duration: star.duration)) {
                progress = 1.0
            }
        }
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let numberOfPoints = 5
        
        for i in 0..<numberOfPoints * 2 {
            let angle = (Double(i) * .pi) / Double(numberOfPoints) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct StarData: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
    var rotation: Double
    var scale: Double
    var blur: CGFloat
    var glowRadius: CGFloat
}

struct ShootingStar: Identifiable {
    let id = UUID()
    let startPosition: CGPoint
    let endPosition: CGPoint
    let color: Color
    let duration: Double
}
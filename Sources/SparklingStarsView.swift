import SwiftUI

struct SparklingStarsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var animatingStars: [StarData] = []
    
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
                }
            }
            .onAppear {
                generateStars(in: geometry.size)
                startTwinkling()
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateStars(in size: CGSize) {
        var stars: [StarData] = []
        
        for _ in 0..<4 {
            stars.append(StarData(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width * 0.2),
                    y: CGFloat.random(in: 0...size.height * 0.2)
                ),
                size: CGFloat.random(in: 4...7),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan].randomElement()!,
                opacity: Double.random(in: 0.4...0.7),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.6...1.0),
                blur: CGFloat.random(in: 0...1.2)
            ))
        }
        
        for _ in 0..<4 {
            stars.append(StarData(
                position: CGPoint(
                    x: CGFloat.random(in: size.width * 0.8...size.width),
                    y: CGFloat.random(in: 0...size.height * 0.2)
                ),
                size: CGFloat.random(in: 4...7),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan].randomElement()!,
                opacity: Double.random(in: 0.4...0.7),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.6...1.0),
                blur: CGFloat.random(in: 0...1.2)
            ))
        }
        
        for _ in 0..<4 {
            stars.append(StarData(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width * 0.2),
                    y: CGFloat.random(in: size.height * 0.8...size.height)
                ),
                size: CGFloat.random(in: 4...7),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan].randomElement()!,
                opacity: Double.random(in: 0.4...0.7),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.6...1.0),
                blur: CGFloat.random(in: 0...1.2)
            ))
        }
        
        for _ in 0..<4 {
            stars.append(StarData(
                position: CGPoint(
                    x: CGFloat.random(in: size.width * 0.8...size.width),
                    y: CGFloat.random(in: size.height * 0.8...size.height)
                ),
                size: CGFloat.random(in: 4...7),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan].randomElement()!,
                opacity: Double.random(in: 0.4...0.7),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.6...1.0),
                blur: CGFloat.random(in: 0...1.2)
            ))
        }
        
        animatingStars = stars
    }
    
    private func startTwinkling() {
        for index in animatingStars.indices {
            let delay = Double.random(in: 0...1.5)
            let duration = Double.random(in: 2.5...4.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    animatingStars[index].opacity = Double.random(in: 0.3...0.8)
                    animatingStars[index].scale = Double.random(in: 0.5...1.1)
                    animatingStars[index].rotation += Double.random(in: -60...60)
                }
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
}
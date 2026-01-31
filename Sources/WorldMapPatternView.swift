import SwiftUI

struct WorldMapPatternView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                themeManager.background
                
                Canvas { context, size in
                    let patternColor = themeManager.worldMapPatternColor
                    
                    // Simplified world map continents as paths
                    drawContinents(context: context, size: size, color: patternColor)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func drawContinents(context: GraphicsContext, size: CGSize, color: Color) {
        let scaleX = size.width / 360.0
        let scaleY = size.height / 180.0
        
        // North America
        var northAmerica = Path()
        northAmerica.move(to: CGPoint(x: convertLon(-170, scaleX: scaleX, width: size.width), y: convertLat(70, scaleY: scaleY, height: size.height)))
        northAmerica.addLine(to: CGPoint(x: convertLon(-50, scaleX: scaleX, width: size.width), y: convertLat(50, scaleY: scaleY, height: size.height)))
        northAmerica.addLine(to: CGPoint(x: convertLon(-80, scaleX: scaleX, width: size.width), y: convertLat(25, scaleY: scaleY, height: size.height)))
        northAmerica.addLine(to: CGPoint(x: convertLon(-110, scaleX: scaleX, width: size.width), y: convertLat(20, scaleY: scaleY, height: size.height)))
        northAmerica.addLine(to: CGPoint(x: convertLon(-120, scaleX: scaleX, width: size.width), y: convertLat(50, scaleY: scaleY, height: size.height)))
        northAmerica.closeSubpath()
        context.fill(northAmerica, with: .color(color))
        
        // South America
        var southAmerica = Path()
        southAmerica.move(to: CGPoint(x: convertLon(-80, scaleX: scaleX, width: size.width), y: convertLat(10, scaleY: scaleY, height: size.height)))
        southAmerica.addLine(to: CGPoint(x: convertLon(-35, scaleX: scaleX, width: size.width), y: convertLat(-5, scaleY: scaleY, height: size.height)))
        southAmerica.addLine(to: CGPoint(x: convertLon(-40, scaleX: scaleX, width: size.width), y: convertLat(-35, scaleY: scaleY, height: size.height)))
        southAmerica.addLine(to: CGPoint(x: convertLon(-70, scaleX: scaleX, width: size.width), y: convertLat(-55, scaleY: scaleY, height: size.height)))
        southAmerica.addLine(to: CGPoint(x: convertLon(-75, scaleX: scaleX, width: size.width), y: convertLat(-20, scaleY: scaleY, height: size.height)))
        southAmerica.closeSubpath()
        context.fill(southAmerica, with: .color(color))
        
        // Europe
        var europe = Path()
        europe.move(to: CGPoint(x: convertLon(-10, scaleX: scaleX, width: size.width), y: convertLat(60, scaleY: scaleY, height: size.height)))
        europe.addLine(to: CGPoint(x: convertLon(40, scaleX: scaleX, width: size.width), y: convertLat(70, scaleY: scaleY, height: size.height)))
        europe.addLine(to: CGPoint(x: convertLon(50, scaleX: scaleX, width: size.width), y: convertLat(50, scaleY: scaleY, height: size.height)))
        europe.addLine(to: CGPoint(x: convertLon(10, scaleX: scaleX, width: size.width), y: convertLat(35, scaleY: scaleY, height: size.height)))
        europe.addLine(to: CGPoint(x: convertLon(-10, scaleX: scaleX, width: size.width), y: convertLat(40, scaleY: scaleY, height: size.height)))
        europe.closeSubpath()
        context.fill(europe, with: .color(color))
        
        // Africa
        var africa = Path()
        africa.move(to: CGPoint(x: convertLon(-20, scaleX: scaleX, width: size.width), y: convertLat(35, scaleY: scaleY, height: size.height)))
        africa.addLine(to: CGPoint(x: convertLon(50, scaleX: scaleX, width: size.width), y: convertLat(30, scaleY: scaleY, height: size.height)))
        africa.addLine(to: CGPoint(x: convertLon(40, scaleX: scaleX, width: size.width), y: convertLat(-35, scaleY: scaleY, height: size.height)))
        africa.addLine(to: CGPoint(x: convertLon(15, scaleX: scaleX, width: size.width), y: convertLat(-35, scaleY: scaleY, height: size.height)))
        africa.addLine(to: CGPoint(x: convertLon(-10, scaleX: scaleX, width: size.width), y: convertLat(0, scaleY: scaleY, height: size.height)))
        africa.closeSubpath()
        context.fill(africa, with: .color(color))
        
        // Asia
        var asia = Path()
        asia.move(to: CGPoint(x: convertLon(50, scaleX: scaleX, width: size.width), y: convertLat(70, scaleY: scaleY, height: size.height)))
        asia.addLine(to: CGPoint(x: convertLon(180, scaleX: scaleX, width: size.width), y: convertLat(65, scaleY: scaleY, height: size.height)))
        asia.addLine(to: CGPoint(x: convertLon(145, scaleX: scaleX, width: size.width), y: convertLat(45, scaleY: scaleY, height: size.height)))
        asia.addLine(to: CGPoint(x: convertLon(100, scaleX: scaleX, width: size.width), y: convertLat(20, scaleY: scaleY, height: size.height)))
        asia.addLine(to: CGPoint(x: convertLon(50, scaleX: scaleX, width: size.width), y: convertLat(30, scaleY: scaleY, height: size.height)))
        asia.closeSubpath()
        context.fill(asia, with: .color(color))
        
        // Australia
        var australia = Path()
        australia.move(to: CGPoint(x: convertLon(115, scaleX: scaleX, width: size.width), y: convertLat(-10, scaleY: scaleY, height: size.height)))
        australia.addLine(to: CGPoint(x: convertLon(155, scaleX: scaleX, width: size.width), y: convertLat(-10, scaleY: scaleY, height: size.height)))
        australia.addLine(to: CGPoint(x: convertLon(150, scaleX: scaleX, width: size.width), y: convertLat(-40, scaleY: scaleY, height: size.height)))
        australia.addLine(to: CGPoint(x: convertLon(115, scaleX: scaleX, width: size.width), y: convertLat(-35, scaleY: scaleY, height: size.height)))
        australia.closeSubpath()
        context.fill(australia, with: .color(color))
    }
    
    private func convertLon(_ lon: Double, scaleX: Double, width: Double) -> Double {
        return (lon + 180) * scaleX
    }
    
    private func convertLat(_ lat: Double, scaleY: Double, height: Double) -> Double {
        return (90 - lat) * scaleY
    }
}
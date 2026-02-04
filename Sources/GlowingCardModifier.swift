import SwiftUI

struct GlowingCardModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    let glowColor: Color
    let cornerRadius: CGFloat
    
    init(glowColor: Color? = nil, cornerRadius: CGFloat = 16) {
        self.glowColor = glowColor ?? Color(red: 1.0, green: 0.4, blue: 0.7)
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(themeManager.cardBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                glowColor.opacity(themeManager.enableGlowEffects ? 0.3 : 0.1),
                                glowColor.opacity(themeManager.enableGlowEffects ? 0.15 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: themeManager.enableGlowEffects ? glowColor.opacity(0.15) : Color.clear,
                radius: themeManager.enableGlowEffects ? 8 : 0,
                x: 0,
                y: 4
            )
    }
}

extension View {
    func glowingCard(glowColor: Color? = nil, cornerRadius: CGFloat = 16) -> some View {
        self.modifier(GlowingCardModifier(glowColor: glowColor, cornerRadius: cornerRadius))
    }
}
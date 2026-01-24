import SwiftUI

struct GlowingCardModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var glowIntensity: CGFloat = 0.3
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
                                glowColor.opacity(glowIntensity),
                                glowColor.opacity(glowIntensity * 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: glowColor.opacity(glowIntensity * 0.6), radius: 12, x: 0, y: 0)
            .shadow(color: glowColor.opacity(glowIntensity * 0.3), radius: 20, x: 0, y: 0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    glowIntensity = 0.8
                }
            }
    }
}

extension View {
    func glowingCard(glowColor: Color? = nil, cornerRadius: CGFloat = 16) -> some View {
        self.modifier(GlowingCardModifier(glowColor: glowColor, cornerRadius: cornerRadius))
    }
}
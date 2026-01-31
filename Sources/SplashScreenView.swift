import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isAnimating = false
    @State private var navigateToMain = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
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
                    themeManager.accentColor.opacity(0.15),
                    themeManager.electricPink.opacity(0.15),
                    themeManager.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(rotationAngle))
            
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
                    ForEach(0..<2) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        themeManager.electricPink.opacity(0.3),
                                        themeManager.electricCyan.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 180 + CGFloat(index * 25), height: 180 + CGFloat(index * 25))
                            .opacity(glowIntensity * 0.4)
                            .scaleEffect(pulseScale + CGFloat(index) * 0.08)
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
                            .frame(width: 180, height: 180)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, themeManager.electricCyan],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .rotationEffect(.degrees(rotationAngle * 0.4))
                        
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .offset(x: 22, y: -22)
                            .rotationEffect(.degrees(-rotationAngle * 0.25))
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                }
                .padding(.bottom, 50)
                
                VStack(spacing: 12) {
                    Text("Device Tuner PRO 26")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
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
                    
                    HStack(spacing: 10) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.neonGreen)
                            .scaleEffect(pulseScale)
                        
                        Text("Manage Your Device")
                            .font(.system(size: 19, weight: .semibold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        themeManager.primaryText,
                                        themeManager.accentColor.opacity(0.9)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.neonGreen)
                            .scaleEffect(pulseScale)
                    }
                }
                .opacity(textOpacity)
                
                Spacer()
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(themeManager.borderColor.opacity(0.3), lineWidth: 3)
                            .frame(width: 45, height: 45)
                        
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
                            .frame(width: 45, height: 45)
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    
                    Text("Loading...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(themeManager.secondaryText)
                }
                .opacity(textOpacity)
                .padding(.bottom, 90)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        themeManager.updateTheme()
        
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.2).delay(0.15)) {
            glowIntensity = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.7).delay(0.4)) {
            textOpacity = 1.0
        }
        
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.12
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.4)) {
                navigateToMain = true
            }
        }
    }
}
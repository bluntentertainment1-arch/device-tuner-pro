import SwiftUI

struct RewardedAdBlockView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var adManager: AdManager
    let message: String
    let onAdWatched: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [themeManager.accentColor, themeManager.electricPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Continue")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                
                Text(message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    Button(action: {
                        onAdWatched()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                            
                            Text("CONTINUE")
                                .font(.system(size: 16, weight: .bold))
                                .tracking(1.2)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [themeManager.accentColor, themeManager.electricPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: themeManager.accentColor.opacity(0.6), radius: 15, x: 0, y: 0)
                    }
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(themeManager.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.borderColor, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(30)
            .background(themeManager.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onAdWatched()
            }
        }
    }
}
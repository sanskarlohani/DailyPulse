import SwiftUI

struct LaunchScreen: View {
    @Binding var isActive: Bool
    @State private var scale: CGFloat = 0.8
    @State private var opacity = 0.5
    @State private var pulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Animated Pulsating Logo
                ZStack {
                    Circle()
                        .stroke(Color.brandBlue.opacity(0.2), lineWidth: 4)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulse)
                        .opacity(2.0 - pulse)
                    
                    Image(systemName: "newspaper.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.brandGradient)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        self.scale = 1.1
                        self.opacity = 1.0
                    }
                    
                    withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                        self.pulse = 2.0
                    }
                }
                
                // Typography
                VStack(spacing: 6) {
                    Text("DailyPulse")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .tracking(1.5)
                        .foregroundStyle(Color.brandGradient)
                    
                    Text("Your Daily Source of Truth")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .opacity(opacity)
                .offset(y: 10)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    LaunchScreen(isActive: .constant(false))
}

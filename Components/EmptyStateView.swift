import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let description: String
    var actionText: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 8)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let actionText = actionText, let action = action {
                Button(action: {
                    Haptics.shared.playLightImpact()
                    action()
                }) {
                    Text(actionText)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.brandGradient)
                        .cornerRadius(20)
                        .shadow(color: Color.brandIndigo.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .bouncePress()
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

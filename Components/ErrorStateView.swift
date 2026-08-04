import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red.opacity(0.8))
                .padding(.bottom, 4)
            
            Text("Connection Issue")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                Haptics.shared.playMediumImpact()
                retryAction()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .fontWeight(.bold)
                    Text("Retry")
                        .fontWeight(.bold)
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color.brandGradient)
                .cornerRadius(22)
                .shadow(color: Color.brandIndigo.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .bouncePress()
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

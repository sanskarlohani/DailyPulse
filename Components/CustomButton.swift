import SwiftUI

struct CustomButton: View {
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    var isPrimary: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Haptics.shared.playLightImpact()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: isPrimary ? .white : .brandBlue))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .fontWeight(.bold)
                    }
                    Text(title)
                        .fontWeight(.bold)
                }
            }
            .font(.subheadline)
            .foregroundColor(isPrimary ? .white : .brandBlue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Group {
                    if isPrimary {
                        Color.brandGradient
                    } else {
                        Color.brandBlue.opacity(0.1)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isPrimary ? Color.clear : Color.brandBlue.opacity(0.2), lineWidth: 1)
            )
        }
        .bouncePress()
        .disabled(isLoading)
    }
}

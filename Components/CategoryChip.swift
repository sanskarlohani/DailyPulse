import SwiftUI

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Haptics.shared.playLightImpact()
            action()
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.brandGradient)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.15), lineWidth: 1)
                )
        }
        .bouncePress()
    }
}

import SwiftUI

extension View {
    /// Applies a premium shimmer effect for skeleton loaders
    func shimmer(isActive: Bool) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }
    
    /// Applies a premium glassmorphic styling
    func glassmorphic(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.08))
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    /// Applies interactive scaling effect on tap/press
    func bouncePress() -> some View {
        self.buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Shimmer Modifier Support
struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { geo in
                        let size = geo.size
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.15),
                                Color.gray.opacity(0.35),
                                Color.gray.opacity(0.15)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: size.width * 2)
                        .offset(x: -size.width + (phase * size.width * 2))
                    }
                    .mask(content)
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1.0
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Button Style Support
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

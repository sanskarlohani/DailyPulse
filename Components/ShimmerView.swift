import SwiftUI

struct ShimmerView: View {
    var width: CGFloat?
    var height: CGFloat
    var cornerRadius: CGFloat = 8
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.15))
            .frame(width: width, height: height)
            .shimmer(isActive: true)
    }
}

// MARK: - Article Skeleton Placeholder
struct ArticleCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShimmerView(height: 180, cornerRadius: 12) // Image placeholder
            
            VStack(alignment: .leading, spacing: 8) {
                ShimmerView(width: 80, height: 14) // Source placeholder
                ShimmerView(height: 20) // Title line 1
                ShimmerView(width: 200, height: 20) // Title line 2
                
                HStack {
                    ShimmerView(width: 100, height: 14) // Time ago placeholder
                    Spacer()
                    ShimmerView(width: 60, height: 14) // Read time placeholder
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - Carousel Skeleton Placeholder
struct CarouselSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShimmerView(height: 220, cornerRadius: 16)
            HStack {
                Spacer()
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

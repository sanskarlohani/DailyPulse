import SwiftUI

struct NewsCard: View {
    let article: Article
    var isFeatured: Bool = false
    
    var body: some View {
        if isFeatured {
            FeaturedCard(article: article)
        } else {
            HorizontalCard(article: article)
        }
    }
}

// MARK: - Featured Hero Card
struct FeaturedCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                // Hero Image
                if let imageURL = article.urlToImage, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ShimmerView(height: 220, cornerRadius: 0)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 220)
                                .clipped()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case .failure:
                            ImageFallbackView(height: 220)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    ImageFallbackView(height: 220)
                }
                
                // Dark gradient overlay for text readability
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Overlay text
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.sourceName.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.brandOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                    
                    Text(article.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
            }
            .frame(height: 220)
            .cornerRadius(16)
            .clipped()
            
            // Bottom details
            HStack {
                Text(article.author ?? "Unknown Author")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("\(article.readTimeInMinutes) min read")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 10)
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Horizontal List Card
struct HorizontalCard: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail image
            if let imageURL = article.urlToImage, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ShimmerView(width: 100, height: 100, cornerRadius: 12)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .cornerRadius(12)
                            .clipped()
                            .transition(.opacity)
                    case .failure:
                        ImageFallbackView(width: 100, height: 100, cornerRadius: 12)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                ImageFallbackView(width: 100, height: 100, cornerRadius: 12)
            }
            
            // Article Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(article.sourceName)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.brandBlue)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(article.publishedAt.formattedTimeAgo())
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let desc = article.articleDescription, !desc.isEmpty {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.top, 1)
                }
                
                Spacer(minLength: 0)
                
                HStack {
                    if let author = article.author, !author.isEmpty {
                        Text(author)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    } else {
                        Text("Staff Reporter")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(article.readTimeInMinutes) min read")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 100)
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Helper Image Fallback
struct ImageFallbackView: View {
    var width: CGFloat? = nil
    var height: CGFloat
    var cornerRadius: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
            VStack(spacing: 8) {
                Image(systemName: "newspaper")
                    .font(.title)
                    .foregroundColor(.gray.opacity(0.5))
                Text("DailyPulse")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray.opacity(0.4))
            }
        }
        .frame(width: width, height: height)
        .cornerRadius(cornerRadius)
    }
}

import SwiftUI

struct ArticleDetailView: View {
    @StateObject var viewModel: ArticleDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Parallax Image Header
                    GeometryReader { geo in
                        let minY = geo.frame(in: .global).minY
                        let height = 300 + (minY > 0 ? minY : 0)
                        
                        ZStack(alignment: .bottomLeading) {
                            if let imgUrlStr = viewModel.article.urlToImage, let url = URL(string: imgUrlStr) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ShimmerView(height: height, cornerRadius: 0)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geo.size.width, height: height)
                                            .clipped()
                                    case .failure:
                                        ImageFallbackView(height: height)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                ImageFallbackView(height: height)
                            }
                            
                            // Image Vignette
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        .frame(width: geo.size.width, height: height)
                        .offset(y: minY > 0 ? -minY : 0)
                    }
                    .frame(height: 300)
                    
                    // Main Article Body
                    VStack(alignment: .leading, spacing: 18) {
                        // Category and source tag
                        HStack(spacing: 8) {
                            Text(viewModel.article.category?.uppercased() ?? "GENERAL")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.brandIndigo)
                                .cornerRadius(4)
                            
                            Text(viewModel.article.sourceName)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.brandBlue)
                            
                            Spacer()
                            
                            Text(viewModel.article.publishedAt.formattedTimeAgo())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 12)
                        
                        // Title
                        Text(viewModel.article.title)
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        // Author and reading time info
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray.opacity(0.6))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.article.author ?? "Staff Writer")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("\(viewModel.article.readTimeInMinutes) min read • Editorial")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground).opacity(0.5))
                        .cornerRadius(12)
                        
                        // Article Content Text
                        if let description = viewModel.article.articleDescription, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                        }
                        
                        if let content = viewModel.article.content {
                            // Trim trailing NewsAPI cutoffs e.g., "... [+1200 chars]"
                            let trimmedContent = content.components(separatedBy: " [+").first ?? content
                            Text(trimmedContent + "\n\nWe provide the highest quality news feed directly from our publishing hubs. Stay updated with all live updates and breaking notifications through our mobile dashboard.")
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineSpacing(8)
                        } else {
                            Text("Full article content is unavailable in this feed overview. Please tap the button below to view the official source publication.")
                                .font(.body)
                                .italic()
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                        }
                        
                        // Action: Open source
                        if let url = URL(string: viewModel.article.url) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "safari")
                                        .fontWeight(.bold)
                                    Text("Open Original Article")
                                        .fontWeight(.bold)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.brandGradient)
                                .cornerRadius(12)
                                .shadow(color: Color.brandIndigo.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            .bouncePress()
                            .padding(.vertical, 12)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Related Articles Section
                        relatedArticlesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Spacing for bottom toolbar
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Bottom Sticky Action Bar
            bottomToolbar
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    Haptics.shared.playLightImpact()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
        .onAppear {
            viewModel.trackReadHistory()
            Task {
                await viewModel.loadRelatedArticles()
            }
        }
    }
    
    // MARK: - Toolbar View
    private var bottomToolbar: some View {
        HStack {
            Spacer()
            
            // Bookmark Button
            Button(action: {
                Haptics.shared.playMediumImpact()
                viewModel.toggleBookmark()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundColor(viewModel.isBookmarked ? .brandIndigo : .primary)
                    Text(viewModel.isBookmarked ? "Saved" : "Save")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .bouncePress()
            
            Spacer()
            
            // Share Button
            Button(action: {
                Haptics.shared.playLightImpact()
                shareArticle()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.primary)
                    Text("Share")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .bouncePress()
            
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Color(.systemBackground)
                .opacity(0.85)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Divider(), alignment: .top
        )
    }
    
    // MARK: - Related Articles Grid
    private var relatedArticlesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Related News")
                .font(.headline)
                .fontWeight(.bold)
            
            if viewModel.isLoadingRelated {
                ProgressView()
                    .frame(height: 80)
            } else if viewModel.relatedArticles.isEmpty {
                Text("No related stories found.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.relatedArticles) { relArticle in
                            // Related article card
                            NavigationLink(destination: ArticleDetailView(
                                viewModel: ArticleDetailViewModel(
                                    article: relArticle,
                                    storageService: viewModel.article.modelContext != nil ? 
                                        StorageService(context: viewModel.article.modelContext!) : 
                                        StorageService(context: viewModel.relatedArticles.first!.modelContext!)
                                )
                            )) {
                                RelatedArticleCard(article: relArticle)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
    }
    
    private func shareArticle() {
        guard let url = URL(string: viewModel.article.url) else { return }
        let text = "Read this article on DailyPulse: \(viewModel.article.title)"
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        // Present Activity VC natively (fallback to UI window search)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // iPad popover configuration support
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Related Article Preview Card
struct RelatedArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let img = article.urlToImage, let url = URL(string: img) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 140, height: 90)
                            .cornerRadius(8)
                            .clipped()
                    } else {
                        ShimmerView(width: 140, height: 90, cornerRadius: 8)
                    }
                }
            } else {
                ImageFallbackView(width: 140, height: 90, cornerRadius: 8)
            }
            
            Text(article.title)
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(2)
                .foregroundColor(.primary)
                .frame(width: 140, alignment: .leading)
            
            Text(article.sourceName)
                .font(.system(size: 10))
                .foregroundColor(.brandBlue)
                .lineLimit(1)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

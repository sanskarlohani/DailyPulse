import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.modelContext) private var modelContext
    
    // Formatter for current date header
    private var headerDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category Chips Bar
                    categorySelectorBar
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                    
                    // Main Content List
                    if viewModel.isLoading {
                        loadingStateView
                    } else if let errorMessage = viewModel.errorMessage, viewModel.articles.isEmpty {
                        ErrorStateView(message: errorMessage) {
                            Task {
                                await viewModel.loadContent()
                            }
                        }
                    } else {
                        articleListView
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isOfflineMode {
                        HStack(spacing: 4) {
                            Image(systemName: "wifi.slash")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Offline")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .task {
                if viewModel.articles.isEmpty {
                    await viewModel.loadContent()
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var categorySelectorBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 40)
    }
    
    private var loadingStateView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Branding
                VStack(alignment: .leading, spacing: 4) {
                    Text(headerDateString.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Text("DailyPulse")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(Color.brandGradient)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 16)
                
                if viewModel.selectedCategory == "General" {
                    CarouselSkeleton()
                }
                ForEach(0..<4) { _ in
                    ArticleCardSkeleton()
                }
            }
        }
    }
    
    private var articleListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Header Branding
                VStack(alignment: .leading, spacing: 4) {
                    Text(headerDateString.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Text("DailyPulse")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(Color.brandGradient)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Carousel section (Only visible on General/First launch)
                if viewModel.selectedCategory == "General" && !viewModel.breakingArticles.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Breaking News")
                            .font(.title3)
                            .fontWeight(.black)
                            .padding(.horizontal)
                        
                        breakingNewsCarousel
                    }
                    .padding(.top, 12)
                }
                
                // Top Headlines header
                HStack {
                    Text(viewModel.selectedCategory == "General" ? "Top Headlines" : "\(viewModel.selectedCategory) News")
                        .font(.title3)
                        .fontWeight(.black)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Article List Cards
                if viewModel.articles.isEmpty {
                    EmptyStateView(
                        systemImage: "newspaper",
                        title: "No Articles",
                        description: "We couldn't find any articles in this category."
                    ) {
                        Task { await viewModel.refreshArticles() }
                    }
                } else {
                    ForEach(viewModel.articles) { article in
                        NavigationLink(destination: ArticleDetailView(
                            viewModel: ArticleDetailViewModel(
                                article: article,
                                storageService: StorageService(context: modelContext)
                            )
                        )) {
                            NewsCard(article: article, isFeatured: false)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            // Infinite Scroll trigger: load more when second-to-last item appears
                            if article == viewModel.articles.last {
                                Task {
                                    await viewModel.fetchArticles(isRefresh: false)
                                }
                            }
                        }
                    }
                    
                    // Loading More Indicator
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .padding(.vertical)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .refreshable {
            Haptics.shared.playLightImpact()
            await viewModel.loadContent()
        }
    }
    
    private var breakingNewsCarousel: some View {
        TabView {
            ForEach(viewModel.breakingArticles) { article in
                NavigationLink(destination: ArticleDetailView(
                    viewModel: ArticleDetailViewModel(
                        article: article,
                        storageService: StorageService(context: modelContext)
                    )
                )) {
                    NewsCard(article: article, isFeatured: true)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 310)
    }
}

#Preview {
    let container = try! ModelContainer(for: Article.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    HomeView(viewModel: HomeViewModel(newsService: MockNewsService.shared))
        .modelContext(container.mainContext)
}

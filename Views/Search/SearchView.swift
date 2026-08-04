import SwiftUI
import SwiftData

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.searchQuery.isEmpty {
                        suggestionsView
                    } else if viewModel.isLoading {
                        loadingStateView
                    } else if let error = viewModel.errorMessage {
                        ErrorStateView(message: error) {
                            Task {
                                await viewModel.performSearch(query: viewModel.searchQuery)
                            }
                        }
                    } else {
                        searchResultsView
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $viewModel.searchQuery, prompt: "Search news, topics, keywords...")
            .onSubmit(of: .search) {
                Task {
                    await viewModel.performSearch(query: viewModel.searchQuery)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var loadingStateView: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<4) { _ in
                    ArticleCardSkeleton()
                }
            }
            .padding(.top)
        }
    }
    
    private var suggestionsView: some View {
        List {
            // Recent Searches Section
            if !viewModel.recentSearches.isEmpty {
                Section {
                    ForEach(viewModel.recentSearches, id: \.self) { search in
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text(search)
                                .foregroundColor(.primary)
                            Spacer()
                            Button(action: {
                                viewModel.deleteRecentSearch(search)
                            }) {
                                Image(systemName: "xmark")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.searchQuery = search
                        }
                    }
                } header: {
                    HStack {
                        Text("Recent Searches")
                        Spacer()
                        Button("Clear All") {
                            viewModel.clearRecentSearches()
                        }
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(.brandBlue)
                    }
                }
            }
            
            // Trending Searches Section
            Section(header: Text("Trending Searches")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.trendingSearches, id: \.self) { trend in
                            Button(action: {
                                Haptics.shared.playLightImpact()
                                viewModel.searchQuery = trend
                            }) {
                                Text(trend)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.brandBlue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.brandBlue.opacity(0.1))
                                    .cornerRadius(18)
                            }
                            .bouncePress()
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(GroupedListStyle())
    }
    
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.searchResults.isEmpty {
                    EmptyStateView(
                        systemImage: "magnifyingglass",
                        title: "No Results",
                        description: "We couldn't find any articles matching '\(viewModel.searchQuery)'."
                    )
                } else {
                    ForEach(viewModel.searchResults) { article in
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
                            // Paginate search results
                            if article == viewModel.searchResults.last {
                                Task {
                                    await viewModel.performSearch(query: viewModel.searchQuery, isRefresh: false)
                                }
                            }
                        }
                    }
                    
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .padding(.vertical)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Article.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    return SearchView(viewModel: SearchViewModel(newsService: MockNewsService.shared))
        .modelContext(container.mainContext)
}

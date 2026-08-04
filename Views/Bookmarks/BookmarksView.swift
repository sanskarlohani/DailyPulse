import SwiftUI
import SwiftData

struct BookmarksView: View {
    @ObservedObject var viewModel: BookmarksViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.bookmarkedArticles.isEmpty {
                        EmptyStateView(
                            systemImage: "bookmark.slash",
                            title: "No Bookmarks",
                            description: "Articles you bookmark will appear here, and will be available for offline reading."
                        )
                    } else if viewModel.filteredArticles.isEmpty {
                        EmptyStateView(
                            systemImage: "magnifyingglass",
                            title: "No Results",
                            description: "No bookmarks matched '\(viewModel.searchQuery)'."
                        )
                    } else {
                        bookmarksList
                    }
                }
            }
            .navigationTitle("Saved Articles")
            .searchable(text: $viewModel.searchQuery, prompt: "Search saved articles...")
            .onAppear {
                viewModel.loadBookmarks()
            }
        }
    }
    
    private var bookmarksList: some View {
        List {
            ForEach(viewModel.filteredArticles) { article in
                ZStack(alignment: .leading) {
                    // Hidden NavigationLink to remove the disclosure chevron in Lists
                    NavigationLink(destination: ArticleDetailView(
                        viewModel: ArticleDetailViewModel(
                            article: article,
                            storageService: StorageService(context: modelContext)
                        )
                    )) {
                        EmptyView()
                    }
                    .opacity(0)
                    
                    NewsCard(article: article, isFeatured: false)
                        .padding(.vertical, 4)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Haptics.shared.playMediumImpact()
                        viewModel.removeBookmark(article)
                    } label: {
                        Label("Delete", systemImage: "bookmark.slash.fill")
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    let container = try! ModelContainer(for: Article.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    return BookmarksView(viewModel: BookmarksViewModel(storageService: StorageService(context: container.mainContext)))
        .modelContext(container.mainContext)
}

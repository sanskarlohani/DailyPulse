import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    
    var body: some View {
        TabView {
            // Tab 1: Home
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Tab 2: Search
            SearchView(viewModel: searchViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            // Tab 3: Bookmarks
            BookmarksTabContainer(modelContext: modelContext)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
            
            // Tab 4: Profile
            ProfileTabContainer(modelContext: modelContext, authViewModel: authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.brandBlue)
    }
}

// MARK: - Container Views for ModelContext-dependent ViewModels
private struct BookmarksTabContainer: View {
    @StateObject private var viewModel: BookmarksViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: BookmarksViewModel(storageService: StorageService(context: modelContext)))
    }
    
    var body: some View {
        BookmarksView(viewModel: viewModel)
    }
}

private struct ProfileTabContainer: View {
    @StateObject private var viewModel: ProfileViewModel
    
    init(modelContext: ModelContext, authViewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(storageService: StorageService(context: modelContext), authViewModel: authViewModel))
    }
    
    var body: some View {
        ProfileView(viewModel: viewModel)
    }
}

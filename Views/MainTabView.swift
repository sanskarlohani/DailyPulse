import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // ViewModels initialized via state to ensure they persist in view hierarchy
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var bookmarksViewModel: BookmarksViewModel?
    @State private var profileViewModel: ProfileViewModel?
    
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
            if let bookmarksVM = bookmarksViewModel {
                BookmarksView(viewModel: bookmarksVM)
                    .tabItem {
                        Label("Saved", systemImage: "bookmark.fill")
                    }
            } else {
                ProgressView()
                    .tabItem {
                        Label("Saved", systemImage: "bookmark.fill")
                    }
            }
            
            // Tab 4: Profile
            if let profileVM = profileViewModel {
                ProfileView(viewModel: profileVM)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            } else {
                ProgressView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
        }
        .onAppear {
            setupViewModels()
        }
        .tint(.brandBlue)
    }
    
    private func setupViewModels() {
        let storage = StorageService(context: modelContext)
        
        if bookmarksViewModel == nil {
            bookmarksViewModel = BookmarksViewModel(storageService: storage)
        }
        
        if profileViewModel == nil {
            profileViewModel = ProfileViewModel(storageService: storage, authViewModel: authViewModel)
        }
    }
}

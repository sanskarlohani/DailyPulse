import SwiftUI
import SwiftData

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    
    
    var body: some View {
        NavigationStack {
            List {
                // Section 1: User Card Info
                Section {
                    userHeaderView
                        .listRowBackground(Color(.systemBackground))
                }
                
                // Section 2: Stats Dashboard
                Section {
                    statsDashboardView
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
                
                // Section 4: Preferences & Toggles
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $viewModel.isDarkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    .tint(.brandIndigo)
                    
                    Toggle(isOn: $viewModel.isNotificationEnabled) {
                        Label("Push Notifications", systemImage: "bell.fill")
                    }
                    .tint(.brandBlue)
                    
                    Picker(selection: $viewModel.selectedLanguage, label: Label("Language", systemImage: "globe")) {
                        ForEach(viewModel.availableLanguages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // Section 5: Reading History
                Section(header: historyHeaderView) {
                    if viewModel.readingHistory.isEmpty {
                        Text("No articles read yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .listRowBackground(Color(.systemBackground))
                    } else {
                        ForEach(viewModel.readingHistory) { article in
                            NavigationLink(destination: ArticleDetailView(
                                viewModel: ArticleDetailViewModel(
                                    article: article,
                                    storageService: StorageService(context: modelContext)
                                )
                            )) {
                                HStack(spacing: 12) {
                                    if let img = article.urlToImage, let url = URL(string: img) {
                                        AsyncImage(url: url) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 50, height: 50)
                                                    .cornerRadius(8)
                                                    .clipped()
                                            } else {
                                                ShimmerView(width: 50, height: 50, cornerRadius: 8)
                                            }
                                        }
                                    } else {
                                        ImageFallbackView(width: 50, height: 50, cornerRadius: 8)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(article.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                        Text(article.sourceName)
                                            .font(.caption2)
                                            .foregroundColor(.brandBlue)
                                    }
                                }
                            }
                            .listRowBackground(Color(.systemBackground))
                        }
                    }
                }
                
                // Section 6: Authentication Operations
                Section {
                    Button(action: {
                        Haptics.shared.playNotification(type: .warning)
                        authViewModel.logout()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "power")
                                .fontWeight(.bold)
                            Text("Sign Out")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .foregroundColor(.red)
                    }
                    .listRowBackground(Color(.systemBackground))
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                viewModel.refreshStatsAndHistory()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var userHeaderView: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                .font(.system(size: 60))
                .symbolRenderingMode(.multicolor)
                .foregroundStyle(Color.brandGradient, Color.brandBlue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(authViewModel.currentUser?.name ?? "Reader")
                    .font(.title3)
                    .fontWeight(.black)
                
                Text(authViewModel.currentUser?.email ?? "guest@dailypulse.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Joined August 2026")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var statsDashboardView: some View {
        HStack(spacing: 16) {
            // Saved count card
            VStack(spacing: 6) {
                Text("\(viewModel.bookmarkCount)")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.brandIndigo)
                Text("Bookmarks")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
            
            // Read count card
            VStack(spacing: 6) {
                Text("\(viewModel.readingHistory.count)")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.brandBlue)
                Text("Articles Read")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
        }
    }
    
    private var historyHeaderView: some View {
        HStack {
            Text("Recent Reading History")
            Spacer()
            if !viewModel.readingHistory.isEmpty {
                Button("Clear") {
                    Haptics.shared.playLightImpact()
                    viewModel.clearHistory()
                }
                .font(.caption)
                .textCase(.none)
                .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Article.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    ProfileView(viewModel: ProfileViewModel(storageService: StorageService(context: container.mainContext), authViewModel: AuthViewModel()))
        .environmentObject(AuthViewModel())
        .modelContext(container.mainContext)
}

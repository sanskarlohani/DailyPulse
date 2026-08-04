import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if authViewModel.isAuthenticated {
            MainTabView()
        } else {
            LoginView(viewModel: authViewModel)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}

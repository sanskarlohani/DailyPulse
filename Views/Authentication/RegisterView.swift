import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.black)
                        
                        Text("Join DailyPulse today to bookmark articles and save your reading history.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 40)
                    
                    // Form fields
                    VStack(spacing: 16) {
                        // Name Field
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            TextField("Full Name", text: $viewModel.name)
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Email Field
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            TextField("Email Address", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Password Field
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            SecureField("Password", text: $viewModel.password)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        CustomButton(title: "Register", isLoading: viewModel.isLoading) {
                            Task {
                                await viewModel.register()
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    
                    // Footer link
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.secondary)
                            Text("Login")
                                .fontWeight(.bold)
                                .foregroundColor(.brandBlue)
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    RegisterView(viewModel: AuthViewModel())
}

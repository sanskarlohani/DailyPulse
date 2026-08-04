import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    @State private var showRegister = false
    @State private var showForgotPassword = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 36) {
                        // Brand Logo Header
                        VStack(spacing: 12) {
                            Image(systemName: "newspaper.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(Color.brandGradient)
                                .shadow(color: Color.brandBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Text("Welcome to DailyPulse")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .multilineTextAlignment(.center)
                            
                            Text("Stay informed with premium stories from trusted global sources.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 40)
                        
                        // Input fields
                        VStack(spacing: 16) {
                            // Email field
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
                            
                            // Password field
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                SecureField("Password", text: $viewModel.password)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Forgot Password Link
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    showForgotPassword = true
                                }
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.brandBlue)
                            }
                            .padding(.top, 2)
                            
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Primary login button
                            CustomButton(title: "Log In", isLoading: viewModel.isLoading) {
                                Task {
                                    await viewModel.login()
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            Text("OR")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 24)
                        
                        // Guest button
                        VStack(spacing: 16) {
                            CustomButton(title: "Continue as Guest", icon: "person.badge.key", isPrimary: false) {
                                Task {
                                    await viewModel.loginAsGuest()
                                }
                            }
                            
                            // Sign up redirect
                            Button(action: {
                                showRegister = true
                            }) {
                                HStack(spacing: 4) {
                                    Text("Don't have an account?")
                                        .foregroundColor(.secondary)
                                    Text("Register Now")
                                        .fontWeight(.bold)
                                        .foregroundColor(.brandBlue)
                                }
                                .font(.subheadline)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showForgotPassword) {
                ForgotPasswordView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}

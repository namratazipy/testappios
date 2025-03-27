import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [ColorTheme.gradientStart, ColorTheme.gradientEnd]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 30) {
                        // Logo and Welcome Text
                        VStack(spacing: 20) {
                            Image(systemName: "bag.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                            
                            Text("Welcome Back!")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Sign in to continue")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 60)
                        
                        // Login Form
                        VStack(spacing: 20) {
                            // Email Field
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(ColorTheme.textSecondary)
                                TextField("Email", text: $authViewModel.email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                            
                            // Password Field
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(ColorTheme.textSecondary)
                                SecureField("Password", text: $authViewModel.password)
                                    .textContentType(.password)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                            
                            // Login Button
                            Button(action: {
                                authViewModel.login()
                            }) {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [ColorTheme.primary, ColorTheme.secondary]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(15)
                                }
                            }
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                            
                            if let error = authViewModel.errorMessage {
                                Text(error)
                                    .foregroundColor(ColorTheme.error)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // Social Login Options
                        VStack(spacing: 20) {
                            Text("Or continue with")
                                .foregroundColor(.white.opacity(0.8))
                            
                            HStack(spacing: 20) {
                                SocialLoginButton(image: "apple.logo", action: {})
                                SocialLoginButton(image: "g.circle.fill", action: {})
                                SocialLoginButton(image: "f.circle.fill", action: {})
                            }
                        }
                        .padding(.top, 30)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isAnimating = true
            }
        }
    }
}

struct SocialLoginButton: View {
    let image: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: image)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
} 
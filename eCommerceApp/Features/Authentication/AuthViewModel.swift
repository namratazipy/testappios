import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            if self.email == "test@example.com" && self.password == "password" {
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Invalid credentials"
            }
            
            self.isLoading = false
        }
    }
    
    func logout() {
        isAuthenticated = false
        email = ""
        password = ""
    }
} 
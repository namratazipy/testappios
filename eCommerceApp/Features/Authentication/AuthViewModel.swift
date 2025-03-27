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
        
        // Simulate API call with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // Accept any non-empty email and password
            if !self.email.isEmpty && !self.password.isEmpty {
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Please enter both email and password"
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
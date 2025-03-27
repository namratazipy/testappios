import SwiftUI

struct UserProfile {
    var name: String
    var email: String
    var phone: String
    var address: String
}

class ProfileViewModel: ObservableObject {
    @Published var profile = UserProfile(
        name: "John Doe",
        email: "john@example.com",
        phone: "+1 234 567 8900",
        address: "123 Main St, City, Country"
    )
    @Published var isEditing = false
    @Published var showingLogoutAlert = false
    
    func updateProfile(_ updatedProfile: UserProfile) {
        profile = updatedProfile
        isEditing = false
    }
    
    func logout() {
        // Handle logout
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                // Profile Header
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.profile.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(viewModel.profile.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Profile Information
                Section(header: Text("Personal Information")) {
                    if viewModel.isEditing {
                        ProfileEditForm(viewModel: viewModel)
                    } else {
                        ProfileInfoRow(title: "Name", value: viewModel.profile.name)
                        ProfileInfoRow(title: "Email", value: viewModel.profile.email)
                        ProfileInfoRow(title: "Phone", value: viewModel.profile.phone)
                        ProfileInfoRow(title: "Address", value: viewModel.profile.address)
                        
                        Button(action: {
                            viewModel.isEditing = true
                        }) {
                            Text("Edit Profile")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Settings
                Section(header: Text("Settings")) {
                    NavigationLink(destination: Text("Notifications")) {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink(destination: Text("Privacy")) {
                        Label("Privacy", systemImage: "lock")
                    }
                    
                    NavigationLink(destination: Text("Help & Support")) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                }
                
                // Logout
                Section {
                    Button(action: {
                        viewModel.showingLogoutAlert = true
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .alert(isPresented: $viewModel.showingLogoutAlert) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout")) {
                        authViewModel.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
        }
    }
}

struct ProfileEditForm: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var editedProfile: UserProfile
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        _editedProfile = State(initialValue: viewModel.profile)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            TextField("Name", text: $editedProfile.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Email", text: $editedProfile.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            TextField("Phone", text: $editedProfile.phone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)
            
            TextField("Address", text: $editedProfile.address)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Button("Cancel") {
                    viewModel.isEditing = false
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Save") {
                    viewModel.updateProfile(editedProfile)
                }
                .foregroundColor(.blue)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
} 
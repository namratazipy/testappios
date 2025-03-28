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
    @Published var notificationsEnabled = true
    @Published var darkModeEnabled = false
    @Published var biometricEnabled = false
    
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
                            .foregroundColor(ColorTheme.primary)
                        
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
                                .foregroundColor(ColorTheme.primary)
                        }
                    }
                }
                
                // Settings
                Section(header: Text("Settings")) {
                    Toggle("Notifications", isOn: $viewModel.notificationsEnabled)
                    Toggle("Dark Mode", isOn: $viewModel.darkModeEnabled)
                    Toggle("Face ID / Touch ID", isOn: $viewModel.biometricEnabled)
                }
                
                // Privacy & Security
                Section(header: Text("Privacy & Security")) {
                    NavigationLink(destination: Text("Privacy Settings")) {
                        SettingsRow(icon: "lock.shield", title: "Privacy Settings")
                    }
                    
                    NavigationLink(destination: Text("Security Settings")) {
                        SettingsRow(icon: "key", title: "Security")
                    }
                    
                    NavigationLink(destination: Text("Password Settings")) {
                        SettingsRow(icon: "key.fill", title: "Change Password")
                    }
                }
                
                // Help & Support
                Section(header: Text("Help & Support")) {
                    NavigationLink(destination: Text("Help Center")) {
                        SettingsRow(icon: "questionmark.circle", title: "Help Center")
                    }
                    
                    NavigationLink(destination: Text("Contact Support")) {
                        SettingsRow(icon: "envelope", title: "Contact Support")
                    }
                    
                    NavigationLink(destination: Text("About")) {
                        SettingsRow(icon: "info.circle", title: "About")
                    }
                }
                
                // Logout
                Section {
                    Button(action: {
                        viewModel.showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                            Text("Logout")
                                .foregroundColor(.red)
                        }
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

struct SettingsRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ColorTheme.primary)
                .frame(width: 24)
            Text(title)
        }
    }
}

struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 2)
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
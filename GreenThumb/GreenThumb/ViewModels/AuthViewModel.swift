import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import LocalAuthentication

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false
    @Published var selectedTab: Int = 0
    @Published var biometricType: LABiometryType = .none
    
    private let db = Firestore.firestore()
    
    init() {
        isAuthenticated = Auth.auth().currentUser != nil
        checkBiometricAvailability()
    }
    
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }
    
    
    func signIn(email: String, password: String) {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            //save to keychain for future face id login
            self.saveCredentials(email: email, password: password)
            self.selectedTab = 0
            self.isAuthenticated = true
        }
    }
    
    
    func register(email: String, password: String, name: String) {
        guard !email.isEmpty && !password.isEmpty && !name.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user else {
                self.isLoading = false
                return
            }
            
            //save to keychain for future face id use
            self.saveCredentials(email: email, password: password)
            
            self.createUserDocument(uid: user.uid, email: email, name: name)
            self.isLoading = false
            self.selectedTab = 0 // 🏠 Reset to Home tab
            self.isAuthenticated = true
        }
    }
    
    //keychain helpers
    private func saveCredentials(email: String, password: String) {
        if let emailData = email.data(using: .utf8),
           let passwordData = password.data(using: .utf8) {
            KeychainHelper.shared.save(emailData, service: "green-thumb-auth", account: "user-email")
            KeychainHelper.shared.save(passwordData, service: "green-thumb-auth", account: "user-password")
        }
    }
    
    private func getCredentials() -> (String, String)? {
        if let emailData = KeychainHelper.shared.read(service: "green-thumb-auth", account: "user-email"),
           let passwordData = KeychainHelper.shared.read(service: "green-thumb-auth", account: "user-password"),
           let email = String(data: emailData, encoding: .utf8),
           let password = String(data: passwordData, encoding: .utf8) {
            return (email, password)
        }
        return nil
    }
    
    //firestore user document creation
    private func createUserDocument(uid: String, email: String, name: String) {
        let data: [String: Any] = [
            "uid": uid,
            "email": email,
            "name": name,
            "handle": name.lowercased().replacingOccurrences(of: " ", with: ""),
            "memberSince": Date(),
            "userType": "Home Grower",
            "gardenCount": 0,
            "plantCount": 0,
            "streakDays": 0,
            "sessionsCount": 0,
            "logEntriesCount": 0
        ]
        
        db.collection("users").document(uid).setData(data, merge: true)
    }
    
    //face id logic implementation
    func signInWithFaceID() {
       //in here check whether the face id option is enabled in the app settings
        let isFaceIDEnabled = UserDefaults.standard.object(forKey: "faceIDEnabled") as? Bool ?? true
        guard isFaceIDEnabled else {
            self.errorMessage = "Face ID is disabled in settings. Please enable it to use biometric login."
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Sign in to your Green Thumb dashboard"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                Task { @MainActor in
                    if success {
                        //face scan successful
                        if let user = Auth.auth().currentUser {
                            //already have a session
                            self.selectedTab = 0 //reset to home tab
                            self.isAuthenticated = true
                        } else if let (email, password) = self.getCredentials() {
                            //no session but have info in the keychain
                            self.isLoading = true
                            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                                self.isLoading = false
                                if let error = error {
                                    self.errorMessage = "Automatic login failed: \(error.localizedDescription)"
                                } else {
                                    self.selectedTab = 0
                                    self.isAuthenticated = true
                                }
                            }
                        } else {
                            //no session and no saved credentials
                            self.errorMessage = "No saved account found. Please sign in manually once to enable Face ID."
                        }
                    } else {
                        if let error = authenticationError as? LAError {
                            switch error.code {
                            case .userCancel: break
                            default: self.errorMessage = "Face ID failed. Please try again."
                            }
                        }
                    }
                }
            }
        } else {
            self.errorMessage = "Face ID is not available or not set up."
        }
    }
    
   
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.selectedTab = 0
            isAuthenticated = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


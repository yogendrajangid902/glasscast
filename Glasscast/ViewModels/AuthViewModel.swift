// AuthViewModel.swift
// Authentication logic.

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLogin = true
    @Published var isLoading = false
    @Published var alertItem: AlertItem?

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    var isValid: Bool {
        email.contains("@") && password.count >= 6
    }

    func submit() async {
        guard isValid else {
            alertItem = AlertItem(message: "Enter a valid email and password (min 6 characters).")
            return
        }
        isLoading = true
        alertItem = nil
        do {
            if isLogin {
                try await authService.signIn(email: email, password: password)
            } else {
                let outcome = try await authService.signUp(email: email, password: password)
                switch outcome {
                case .confirmationRequired:
                    alertItem = AlertItem(message: "Account created. Check your email to confirm your account.")
                case .existingAccount:
                    alertItem = AlertItem(message: "This email is already registered. Please log in instead.")
                case .signedIn:
                    break
                }
            }
        } catch {
            alertItem = AlertItem(message: mapError(error))
        }
        isLoading = false
    }

    private func mapError(_ error: Error) -> String {
        let message = error.localizedDescription
        let lowercased = message.lowercased()
        if lowercased.contains("already registered") || lowercased.contains("already exists") {
            return "This email is already registered. Try logging in instead."
        }
        if lowercased.contains("invalid login credentials") {
            return "Invalid email or password."
        }
        return message
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

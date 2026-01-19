// SettingsViewModel.swift
// Settings logic.

import Foundation
import Combine
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading = false

    @AppStorage("temperatureUnit") var storedUnit = TemperatureUnit.celsius.rawValue

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func signOut() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

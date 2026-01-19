// AuthService.swift
// Supabase auth wrapper.

import Foundation
import Supabase

enum SignUpOutcome {
    case signedIn
    case confirmationRequired
    case existingAccount
}

struct AuthService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws -> SignUpOutcome {
        let response = try await client.auth.signUp(email: email, password: password)
        if response.session != nil {
            return .signedIn
        }
        if response.user.identities?.isEmpty == true {
            return .existingAccount
        }
        return .confirmationRequired
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
}

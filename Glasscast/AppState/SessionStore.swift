// SessionStore.swift
// Observes Supabase auth state.

import Foundation
import Combine
import Supabase

@MainActor
final class SessionStore: ObservableObject {
    @Published var user: User?
    @Published var isLoading = true

    private let client: SupabaseClient
    private var authTask: Task<Void, Never>?

    init(client: SupabaseClient) {
        self.client = client
        authTask = Task {
            await loadInitialSession()
            await observeAuthChanges()
        }
    }

    deinit {
        authTask?.cancel()
    }

    private func loadInitialSession() async {
        do {
            let session = try await client.auth.session
            if session.isExpired {
                user = nil
            } else {
                user = session.user
            }
        } catch {
            user = nil
        }
        isLoading = false
    }

    private func observeAuthChanges() async {
        for await state in client.auth.authStateChanges {
            switch state.event {
            case .signedIn:
                user = state.session?.user
            case .signedOut:
                user = nil
            default:
                break
            }
        }
    }
}

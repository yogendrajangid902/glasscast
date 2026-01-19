// AppContainer.swift
// Dependency container for services.

import Foundation
import Combine
import Supabase

@MainActor
final class AppContainer: ObservableObject {
    let supabase: SupabaseClient?
    let authService: AuthService?
    let favoritesService: FavoritesService?
    let weatherService: WeatherService?
    let configurationError: String?

    init() {
        guard let url = Config.supabaseURL,
              let anonKey = Config.supabaseAnonKey,
              let weatherKey = Config.openWeatherAPIKey else {
            supabase = nil
            authService = nil
            favoritesService = nil
            weatherService = nil
            configurationError = "Missing configuration. Please set Info.plist keys for Supabase and OpenWeather."
            return
        }

        let options = SupabaseClientOptions(
            auth: .init(emitLocalSessionAsInitialSession: true)
        )
        let client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey, options: options)
        supabase = client
        authService = AuthService(client: client)
        favoritesService = FavoritesService(client: client)
        weatherService = WeatherService(apiKey: weatherKey)
        configurationError = nil
    }
}

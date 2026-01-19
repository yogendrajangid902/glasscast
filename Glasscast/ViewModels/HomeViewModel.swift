// HomeViewModel.swift
// Weather and favorites logic.

import Foundation
import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var favorites: [FavoriteCity] = []
    @Published var selectedCity: FavoriteCity?
    @Published var selectedForecastDay: ForecastDay?
    @Published var currentWeather: CurrentWeather?
    @Published var forecast: [ForecastDay] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @AppStorage("temperatureUnit") private var storedUnit = TemperatureUnit.celsius.rawValue

    private let favoritesService: FavoritesService
    private let weatherService: WeatherService

    init(favoritesService: FavoritesService, weatherService: WeatherService) {
        self.favoritesService = favoritesService
        self.weatherService = weatherService
    }

    var unit: TemperatureUnit {
        TemperatureUnit(rawValue: storedUnit) ?? .celsius
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await favoritesService.fetchFavorites()
            favorites = fetched
            selectedCity = fetched.first
            try await refreshWeather()
        } catch {
            if !isCancellation(error) {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }

    func refreshWeather() async throws {
        guard let city = selectedCity else {
            currentWeather = nil
            forecast = []
            return
        }
        async let current = weatherService.fetchCurrent(lat: city.lat, lon: city.lon, unit: unit)
        async let forecast = weatherService.fetchForecast(lat: city.lat, lon: city.lon, unit: unit)
        let (currentResult, forecastResult) = try await (current, forecast)
        currentWeather = currentResult
        self.forecast = forecastResult
    }

    func refresh() async {
        errorMessage = nil
        do {
            try await refreshWeather()
        } catch {
            if !isCancellation(error) {
                errorMessage = error.localizedDescription
            }
        }
    }

    func select(city: FavoriteCity) async {
        selectedCity = city
        selectedForecastDay = nil
        await refresh()
    }

    func select(day: ForecastDay) {
        if selectedForecastDay?.id == day.id {
            selectedForecastDay = nil
        } else {
            selectedForecastDay = day
        }
    }

    func removeFavorite(id: UUID) async {
        do {
            try await favoritesService.removeFavorite(id: id)
            favorites.removeAll { $0.id == id }
            if selectedCity?.id == id {
                selectedCity = favorites.first
                await refresh()
            }
        } catch {
            if !isCancellation(error) {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }
}

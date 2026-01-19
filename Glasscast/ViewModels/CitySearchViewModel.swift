// CitySearchViewModel.swift
// Search and add cities.

import Foundation
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [GeocodeCity] = []
    @Published var favorites: [FavoriteCity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let favoritesService: FavoritesService
    private let weatherService: WeatherService
    private var searchTask: Task<Void, Never>?

    init(favoritesService: FavoritesService, weatherService: WeatherService) {
        self.favoritesService = favoritesService
        self.weatherService = weatherService
    }

    func loadFavorites() async {
        do {
            favorites = try await favoritesService.fetchFavorites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isFavorite(_ city: GeocodeCity) -> Bool {
        favorites.contains(where: { $0.lat == city.lat && $0.lon == city.lon })
    }

    func updateQuery(_ text: String) {
        query = text
        searchTask?.cancel()
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await search()
        }
    }

    func search() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await weatherService.searchCities(query: query)
            results = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addFavorite(from city: GeocodeCity) async {
        guard !isFavorite(city) else { return }
        do {
            let insert = FavoriteCityInsert(city_name: city.displayName, lat: city.lat, lon: city.lon)
            let added = try await favoritesService.addFavorite(insert)
            favorites.append(added)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

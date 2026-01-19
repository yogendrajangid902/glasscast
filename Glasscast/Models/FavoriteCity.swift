// FavoriteCity.swift
// Favorite city models.

import Foundation

struct FavoriteCity: Identifiable, Codable, Equatable {
    let id: UUID
    let user_id: UUID
    let city_name: String
    let lat: Double
    let lon: Double
    let created_at: String

    static let placeholder = FavoriteCity(id: UUID(), user_id: UUID(), city_name: "-", lat: 0, lon: 0, created_at: "")
}

struct FavoriteCityInsert: Codable {
    let city_name: String
    let lat: Double
    let lon: Double
}

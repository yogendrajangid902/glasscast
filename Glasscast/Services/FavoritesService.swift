// FavoritesService.swift
// CRUD for favorite_cities.

import Foundation
import Supabase

struct FavoritesService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchFavorites() async throws -> [FavoriteCity] {
        let response: [FavoriteCity] = try await client
            .from("favorite_cities")
            .select()
            .order("created_at", ascending: true)
            .execute()
            .value
        return response
    }

    func addFavorite(_ city: FavoriteCityInsert) async throws -> FavoriteCity {
        let response: [FavoriteCity] = try await client
            .from("favorite_cities")
            .insert(city)
            .select()
            .execute()
            .value
        return response.first ?? FavoriteCity.placeholder
    }

    func removeFavorite(id: UUID) async throws {
        _ = try await client
            .from("favorite_cities")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}

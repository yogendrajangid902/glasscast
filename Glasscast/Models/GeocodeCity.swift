// GeocodeCity.swift
// OpenWeather geocoding model.

import Foundation

struct GeocodeCity: Identifiable, Codable, Equatable {
    let name: String
    let state: String?
    let country: String
    let lat: Double
    let lon: Double

    var id: String {
        "\(name)-\(lat)-\(lon)"
    }

    var displayName: String {
        if let state, !state.isEmpty {
            return "\(name), \(state), \(country)"
        }
        return "\(name), \(country)"
    }
}

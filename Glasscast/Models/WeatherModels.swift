// WeatherModels.swift
// Domain models for weather.

import Foundation

struct CurrentWeather: Codable, Equatable {
    let temp: Double
    let condition: String
    let high: Double
    let low: Double
    let icon: String
    let humidity: Int
    let windSpeed: Double
    let windDeg: Double?
    let visibilityMeters: Double?
    let uvIndex: Double?
}

struct ForecastDay: Identifiable, Codable, Equatable {
    let id = UUID()
    let date: Date
    let min: Double
    let max: Double
    let condition: String
    let icon: String
}

enum TemperatureUnit: String, CaseIterable {
    case celsius
    case fahrenheit

    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }

    var apiValue: String {
        switch self {
        case .celsius: return "metric"
        case .fahrenheit: return "imperial"
        }
    }
}

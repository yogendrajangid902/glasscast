// WeatherService.swift
// OpenWeather API client.

import Foundation

struct WeatherService {
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func searchCities(query: String) async throws -> [GeocodeCity] {
        guard let url = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&limit=10&appid=\(apiKey)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await session.data(from: url)
#if DEBUG
        if let raw = String(data: data, encoding: .utf8) {
            print("OpenWeather Geocode Response:", raw)
        }
#endif
        let decoded = try JSONDecoder().decode([GeocodeCity].self, from: data)
        return decoded
    }

    func fetchCurrent(lat: Double, lon: Double, unit: TemperatureUnit) async throws -> CurrentWeather {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=\(unit.apiValue)&appid=\(apiKey)") else {
            throw URLError(.badURL)
        }
        async let uvValue = fetchUVIndex(lat: lat, lon: lon)
        let (data, _) = try await session.data(from: url)
#if DEBUG
        if let raw = String(data: data, encoding: .utf8) {
            print("OpenWeather Current Response:", raw)
        }
#endif
        let decoded = try JSONDecoder().decode(CurrentWeatherResponse.self, from: data)
        let uv = try? await uvValue
        return decoded.toModel(uvIndex: uv)
    }

    func fetchForecast(lat: Double, lon: Double, unit: TemperatureUnit) async throws -> [ForecastDay] {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=\(unit.apiValue)&appid=\(apiKey)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await session.data(from: url)
#if DEBUG
        if let raw = String(data: data, encoding: .utf8) {
            print("OpenWeather Forecast Response:", raw)
        }
#endif
        let decoded = try JSONDecoder().decode(ForecastResponse.self, from: data)
        return decoded.toDailyForecast()
    }
}

private struct CurrentWeatherResponse: Decodable {
    struct Weather: Decodable {
        let main: String
        let description: String
        let icon: String
    }
    struct Main: Decodable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
        let humidity: Int
    }
    struct Wind: Decodable {
        let speed: Double
        let deg: Double?
    }

    let weather: [Weather]
    let main: Main
    let wind: Wind
    let visibility: Double?

    func toModel(uvIndex: Double?) -> CurrentWeather {
        let condition = weather.first?.main ?? "-"
        let icon = weather.first?.icon ?? "01d"
        return CurrentWeather(
            temp: main.temp,
            condition: condition,
            high: main.temp_max,
            low: main.temp_min,
            icon: icon,
            humidity: main.humidity,
            windSpeed: wind.speed,
            windDeg: wind.deg,
            visibilityMeters: visibility,
            uvIndex: uvIndex
        )
    }
}

private struct ForecastResponse: Decodable {
    struct City: Decodable {
        let timezone: Int
    }
    struct Item: Decodable {
        struct Main: Decodable {
            let temp_min: Double
            let temp_max: Double
        }
        struct Weather: Decodable {
            let main: String
            let icon: String
        }
        let dt: TimeInterval
        let main: Main
        let weather: [Weather]
    }

    let list: [Item]
    let city: City

    func toDailyForecast() -> [ForecastDay] {
        let offset = city.timezone
        var grouped: [String: [Item]] = [:]

        for item in list {
            let date = Date(timeIntervalSince1970: item.dt + TimeInterval(offset))
            let key = ForecastResponse.dayKey(for: date)
            grouped[key, default: []].append(item)
        }

        let todayKey = ForecastResponse.dayKey(for: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + TimeInterval(offset)))
        let sortedKeys = grouped.keys.sorted().filter { $0 != todayKey }
        var days: [ForecastDay] = []
        for key in sortedKeys.prefix(5) {
            guard let items = grouped[key] else { continue }
            let minTemp = items.map { $0.main.temp_min }.min() ?? 0
            let maxTemp = items.map { $0.main.temp_max }.max() ?? 0
            let representative = ForecastResponse.middayItem(from: items, offset: offset)
            let condition = representative?.weather.first?.main ?? "-"
            let icon = representative?.weather.first?.icon ?? "01d"
            let date = ForecastResponse.dateFromKey(key)
            days.append(ForecastDay(date: date, min: minTemp, max: maxTemp, condition: condition, icon: icon))
        }
        return days
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    private static func dateFromKey(_ key: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: key) ?? Date()
    }

    private static func middayItem(from items: [Item], offset: Int) -> Item? {
        let targetHour = 12
        return items.min(by: { left, right in
            let leftHour = hour(from: left.dt, offset: offset)
            let rightHour = hour(from: right.dt, offset: offset)
            return abs(leftHour - targetHour) < abs(rightHour - targetHour)
        })
    }

    private static func hour(from dt: TimeInterval, offset: Int) -> Int {
        let date = Date(timeIntervalSince1970: dt + TimeInterval(offset))
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.hour, from: date)
    }
}

private struct UVResponse: Decodable {
    let value: Double?
}

private extension WeatherService {
    func fetchUVIndex(lat: Double, lon: Double) async throws -> Double? {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/uvi?lat=\(lat)&lon=\(lon)&appid=\(apiKey)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await session.data(from: url)
        let decoded = try JSONDecoder().decode(UVResponse.self, from: data)
        return decoded.value
    }
}

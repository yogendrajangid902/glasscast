// Config.swift
// Safe Info.plist config reader.

import Foundation

enum Config {
    static var supabaseURL: URL? {
        guard let value = value(for: "SUPABASE_URL") else { return nil }
        return URL(string: value)
    }

    static var supabaseAnonKey: String? {
        value(for: "SUPABASE_ANON_KEY")
    }

    static var openWeatherAPIKey: String? {
        value(for: "OPENWEATHER_API_KEY")
    }

    static func value(for key: String) -> String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

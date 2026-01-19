// ForecastCard.swift
// Forecast day card.

import SwiftUI

struct ForecastCard: View {
    let day: ForecastDay
    let unit: TemperatureUnit
    let isSelected: Bool

    var body: some View {
        GlassCard {
            VStack(spacing: 8) {
                Text(day.date, format: .dateTime.weekday(.abbreviated))
                    .font(.caption.weight(.semibold))
                Image(systemName: iconName)
                    .font(.system(size: 22))
                Text("\(Int(day.max.rounded()))\(unit.symbol)")
                    .font(.headline)
                Text("\(Int(day.min.rounded()))\(unit.symbol)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80)
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            }
        }
    }

    private var iconName: String {
        switch day.icon {
        case "01d", "01n": return "sun.max.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n", "04d", "04n": return "cloud.fill"
        case "09d", "09n", "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.rain.fill"
        case "13d", "13n": return "snowflake"
        default: return "cloud.sun"
        }
    }
}

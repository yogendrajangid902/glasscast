// ForecastRow.swift
// 5-day list row.

import SwiftUI

struct ForecastRow: View {
    let day: ForecastDay
    let unit: TemperatureUnit
    let isSelected: Bool
    let globalMin: Double
    let globalMax: Double

    var body: some View {
        HStack(spacing: 14) {
            Text(day.date, format: .dateTime.weekday(.abbreviated))
                .font(.subheadline.weight(.semibold))
                .frame(width: 46, alignment: .leading)

            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 24)

            Text("\(Int(day.min.rounded()))\(unit.symbol)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .trailing)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 6)
                    Capsule()
                        .fill(LinearGradient(colors: [Color.cyan.opacity(0.8), Color.yellow.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: barWidth(totalWidth: proxy.size.width), height: 6)
                        .offset(x: barOffset(totalWidth: proxy.size.width))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 6)
            .padding(.top, 8)

            Text("\(Int(day.max.rounded()))\(unit.symbol)")
                .font(.subheadline.weight(.semibold))
                .frame(width: 44, alignment: .leading)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.cyan.opacity(0.6) : Color.white.opacity(0.12), lineWidth: 1)
        )
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

    private var barRange: Double {
        max(1, globalMax - globalMin)
    }

    private func barWidth(totalWidth: Double) -> Double {
        let span = day.max - day.min
        let normalized = max(0.1, span / barRange)
        return totalWidth * normalized
    }

    private func barOffset(totalWidth: Double) -> Double {
        let normalized = (day.min - globalMin) / barRange
        return totalWidth * normalized
    }
}

// HomeView.swift
// Home weather screen.

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @AppStorage("temperatureUnit") private var storedUnit = TemperatureUnit.celsius.rawValue

    var body: some View {
        NavigationStack {
            ZStack {
                background
                VStack {
                    ScrollView {
                        VStack(spacing: 20) {
                        if viewModel.favorites.isEmpty {
                            emptyState
                        } else {
                            favoritesSelector
                            heroWeatherCard
                            if viewModel.selectedForecastDay == nil {
                                detailsGrid
                            }
                            forecastSection
                        }

                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    .padding(.bottom, 96)
                    }
                    .refreshable { await viewModel.refresh() }
                }
                
                .overlay(alignment: .top) {
                    if viewModel.isLoading {
                        LoadingView(title: "Loading weather")
                            .transition(.opacity)
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.automatic)
            .onChange(of: storedUnit) { _ in
                Task { await viewModel.refresh() }
            }
            .task {
                await viewModel.load()
            }
        }
    }

    private var favoritesSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.favorites) { city in
                    HStack(spacing: 2) {
                        Button(action: {
                            Task { await viewModel.select(city: city) }
                        }, label: {
                            Text(city.city_name)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(viewModel.selectedCity?.id == city.id ? Color.white.opacity(0.35) : Color.white.opacity(0.15))
                                )
                        })
                        .buttonStyle(.plain)

                        Button {
                            Task { await viewModel.removeFavorite(id: city.id) }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.primary)
//                                .frame(width: 25, height: 25)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(viewModel.selectedCity?.id == city.id ? Color.white.opacity(0.35) : Color.white.opacity(0.15))
                                )
                        }
                        .buttonStyle(.plain)
//                        .offset(x: 6, y: -6)
                    }
                }
            }
        }
    }

    private var heroWeatherCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.selectedCity?.city_name ?? "")
                            .font(.headline)
                        Text(heroCondition)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: heroIcon)
                        .font(.system(size: 26))
                        .id(heroIcon)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .animation(.easeInOut(duration: 0.2), value: heroIcon)
                }

                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("\(Int(heroPrimaryTemp.rounded()))\(viewModel.unit.symbol)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up")
                            Text("\(Int(heroHigh.rounded()))\(viewModel.unit.symbol)")
                        }
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down")
                            Text("\(Int(heroLow.rounded()))\(viewModel.unit.symbol)")
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                }

                Divider()
                    .opacity(0.3)

                HStack {
                    Text(heroFooterLeft)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(heroFooterRight)
                        .font(.caption.weight(.semibold))
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("5-Day Forecast")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(viewModel.unit.symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: 10) {
                ForEach(viewModel.forecast) { day in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.select(day: day)
                        }
                    }, label: {
                        ForecastRow(
                            day: day,
                            unit: viewModel.unit,
                            isSelected: viewModel.selectedForecastDay?.id == day.id,
                            globalMin: forecastMin,
                            globalMax: forecastMax
                        )
                    })
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var detailsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Wind", systemImage: "wind")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(windSpeedText)
                            .font(.title3.bold())
                        Text(windSpeedUnit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(windDirectionText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Humidity", systemImage: "drop")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(humidityValue)")
                            .font(.title3.bold())
                        Text("%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 6)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Color.cyan.opacity(0.7))
                                .frame(width: max(8, CGFloat(humidityValue)) * 0.6, height: 6)
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("UV Index", systemImage: "sun.max")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(uvValueText)
                        .font(.title3.bold())
                    Text(uvDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Visibility", systemImage: "eye")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(visibilityValueText)
                        .font(.title3.bold())
                    Text(visibilityDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 12) {
                Text("No favorites yet")
                    .font(.headline)
                Text("Search for a city to add it to your favorites.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var currentIcon: String {
        switch viewModel.currentWeather?.icon {
        case "01d", "01n": return "sun.max.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n", "04d", "04n": return "cloud.fill"
        case "09d", "09n", "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.rain.fill"
        case "13d", "13n": return "snowflake"
        default: return "cloud.sun"
        }
    }

    private var heroCondition: String {
        viewModel.selectedForecastDay?.condition ?? viewModel.currentWeather?.condition ?? "-"
    }

    private var heroIcon: String {
        if let day = viewModel.selectedForecastDay {
            return iconName(for: day.icon)
        }
        return currentIcon
    }

    private var heroPrimaryTemp: Double {
        if let day = viewModel.selectedForecastDay {
            return day.max
        }
        return viewModel.currentWeather?.temp ?? 0
    }

    private var heroHigh: Double {
        if let day = viewModel.selectedForecastDay {
            return day.max
        }
        return viewModel.currentWeather?.high ?? 0
    }

    private var heroLow: Double {
        if let day = viewModel.selectedForecastDay {
            return day.min
        }
        return viewModel.currentWeather?.low ?? 0
    }

    private var heroFooterLeft: String {
        if let day = viewModel.selectedForecastDay {
            return day.date.formatted(.dateTime.weekday(.wide))
        }
        return "Updated just now"
    }

    private var heroFooterRight: String {
        viewModel.selectedForecastDay == nil ? "5-day outlook" : "Tap again to reset"
    }

    private var navigationTitle: String {
        if let day = viewModel.selectedForecastDay {
            return day.date.formatted(.dateTime.weekday(.wide))
        }
        return "Today"
    }

    private func iconName(for code: String) -> String {
        switch code {
        case "01d", "01n": return "sun.max.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n", "04d", "04n": return "cloud.fill"
        case "09d", "09n", "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.rain.fill"
        case "13d", "13n": return "snowflake"
        default: return "cloud.sun"
        }
    }

    private var forecastMin: Double {
        viewModel.forecast.map { $0.min }.min() ?? 0
    }

    private var forecastMax: Double {
        viewModel.forecast.map { $0.max }.max() ?? 0
    }

    private var windSpeedText: String {
        let speed = viewModel.currentWeather?.windSpeed ?? 0
        return String(format: "%.0f", speed)
    }

    private var windSpeedUnit: String {
        viewModel.unit == .fahrenheit ? "mph" : "m/s"
    }

    private var windDirectionText: String {
        guard let deg = viewModel.currentWeather?.windDeg else { return "Calm" }
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((deg + 22.5) / 45.0) & 7
        return directions[index]
    }

    private var humidityValue: Int {
        viewModel.currentWeather?.humidity ?? 0
    }

    private var visibilityValueText: String {
        guard let meters = viewModel.currentWeather?.visibilityMeters else { return "-" }
        if viewModel.unit == .fahrenheit {
            let miles = meters / 1609.34
            return String(format: "%.0f mi", miles)
        }
        let km = meters / 1000.0
        return String(format: "%.0f km", km)
    }

    private var visibilityDescription: String {
        guard let meters = viewModel.currentWeather?.visibilityMeters else { return "Unavailable" }
        if meters >= 9000 { return "Clear" }
        if meters >= 5000 { return "Moderate" }
        return "Low"
    }

    private var uvValueText: String {
        guard let uv = viewModel.currentWeather?.uvIndex else { return "-" }
        return String(format: "%.0f", uv)
    }

    private var uvDescription: String {
        guard let uv = viewModel.currentWeather?.uvIndex else { return "Unavailable" }
        switch uv {
        case 0..<3: return "Low"
        case 3..<6: return "Moderate"
        case 6..<8: return "High"
        case 8..<11: return "Very High"
        default: return "Extreme"
        }
    }

    private var background: some View {
        WeatherBackground(
            condition: viewModel.currentWeather?.condition,
            iconCode: viewModel.currentWeather?.icon
        )
        .ignoresSafeArea()
    }
}

private struct WeatherBackground: View {
    let condition: String?
    let iconCode: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                LinearGradient(
                    colors: overlayColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.6)
            )

            if isDaytime {
                Circle()
                    .fill(Color.yellow.opacity(0.5))
                    .frame(width: 240, height: 240)
                    .blur(radius: 20)
                    .offset(x: 140, y: -220)
                Circle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .blur(radius: 10)
                    .offset(x: 120, y: -200)
            } else {
                Circle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 160, height: 160)
                    .blur(radius: 10)
                    .offset(x: 140, y: -220)
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 260, height: 260)
                    .blur(radius: 30)
                    .offset(x: -160, y: -260)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: gradientColors)
    }

    private var gradientColors: [Color] {
        switch timeOfDay {
        case .morning:
            return [Color.orange.opacity(0.35), Color.blue.opacity(0.25), Color.cyan.opacity(0.35)]
        case .day:
            return [Color.blue.opacity(0.35), Color.cyan.opacity(0.2), Color.mint.opacity(0.35)]
        case .evening:
            return [Color.pink.opacity(0.35), Color.indigo.opacity(0.3), Color.blue.opacity(0.35)]
        case .night:
            return [Color.black.opacity(0.6), Color.indigo.opacity(0.5), Color.blue.opacity(0.35)]
        }
    }

    private var overlayColors: [Color] {
        let isCloudy = (condition ?? "").lowercased().contains("cloud")
        if isCloudy {
            return [Color.white.opacity(0.08), Color.black.opacity(0.15)]
        }
        return [Color.white.opacity(0.05), Color.black.opacity(0.1)]
    }

    private var isDaytime: Bool {
        guard let iconCode else { return true }
        return iconCode.contains("d")
    }

    private var timeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 10 { return .morning }
        if hour >= 10 && hour < 17 { return .day }
        if hour >= 17 && hour < 20 { return .evening }
        return .night
    }
}

private enum TimeOfDay {
    case morning
    case day
    case evening
    case night
}

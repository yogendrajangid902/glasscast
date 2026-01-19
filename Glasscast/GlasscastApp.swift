// GlasscastApp.swift
// App entry point.

import SwiftUI
import Supabase

@main
struct GlasscastApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            Group {
                if let error = container.configurationError {
                    ConfigErrorView(message: error)
                } else if let supabase = container.supabase,
                          let authService = container.authService,
                          let favoritesService = container.favoritesService,
                          let weatherService = container.weatherService {
                    RootView(
                        sessionStore: SessionStore(client: supabase),
                        authService: authService,
                        favoritesService: favoritesService,
                        weatherService: weatherService
                    )
                } else {
                    ConfigErrorView(message: "Unexpected configuration issue.")
                }
            }
        }
    }
}

private struct ConfigErrorView: View {
    let message: String

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            GlassCard {
                VStack(spacing: 12) {
                    Text("Glasscast")
                        .font(.largeTitle.bold())
                    Text(message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
            }
            .padding(24)
        }
    }
}

private struct RootView: View {
    @StateObject private var sessionStore: SessionStore
    private let authService: AuthService
    private let favoritesService: FavoritesService
    private let weatherService: WeatherService

    init(sessionStore: SessionStore, authService: AuthService, favoritesService: FavoritesService, weatherService: WeatherService) {
        _sessionStore = StateObject(wrappedValue: sessionStore)
        self.authService = authService
        self.favoritesService = favoritesService
        self.weatherService = weatherService
    }

    var body: some View {
        ZStack {
            if sessionStore.isLoading {
                LoadingView(title: "Checking session")
            } else if sessionStore.user == nil {
                AuthView(viewModel: AuthViewModel(authService: authService))
            } else {
                MainTabView(
                    favoritesService: favoritesService,
                    weatherService: weatherService,
                    authService: authService,
                    userEmail: sessionStore.user?.email ?? ""
                )
            }
        }
        .animation(.easeInOut, value: sessionStore.user?.id)
    }
}

enum Tabs{
    case home, settings, search
}

private struct MainTabView: View {
    let favoritesService: FavoritesService
    let weatherService: WeatherService
    let authService: AuthService
    @State var selectedTab: Tabs = .home
    let userEmail: String
    @State var searchText: String = ""
    @StateObject private var searchViewModel: CitySearchViewModel
    @FocusState private var searchFocused: Bool

    init(favoritesService: FavoritesService, weatherService: WeatherService, authService: AuthService, userEmail: String) {
        self.favoritesService = favoritesService
        self.weatherService = weatherService
        self.authService = authService
        self.userEmail = userEmail
        _searchViewModel = StateObject(wrappedValue: CitySearchViewModel(favoritesService: favoritesService, weatherService: weatherService))
    }

    var body: some View {
        TabView (selection: $selectedTab){
            Tab("Home", systemImage: "cloud.sun", value: .home){
                HomeView(viewModel: HomeViewModel(favoritesService: favoritesService, weatherService: weatherService))
            }
           
         
            
            Tab("Settings", systemImage: "gear", value: .settings){
                SettingsView(viewModel: SettingsViewModel(authService: authService), userEmail: userEmail)
            }
            
            Tab(value: .search, role: .search, content: {
                NavigationStack {
                    CitySearchView(viewModel: searchViewModel, usesSystemSearchBar: true)
                }
                .searchable(text: $searchText)
                .searchFocused($searchFocused)
                .searchDictationBehavior(.automatic)
                .onChange(of: searchText) { newValue in
                    searchViewModel.updateQuery(newValue)
                }
                .task {
                    await searchViewModel.loadFavorites()
                }
                
            })
                        
           
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == .search {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    searchFocused = true
                }
            } else {
                searchFocused = false
            }
        }
        
    }
}

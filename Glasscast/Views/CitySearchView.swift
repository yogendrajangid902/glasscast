// CitySearchView.swift
// Search cities and add favorites.

import SwiftUI

struct CitySearchView: View {
    @StateObject var viewModel: CitySearchViewModel
    let usesSystemSearchBar: Bool
    init(viewModel: CitySearchViewModel, usesSystemSearchBar: Bool = false) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.usesSystemSearchBar = usesSystemSearchBar
    }

    var body: some View {
        ZStack {
            background
            VStack(spacing: 12) {
                if viewModel.isLoading {
                    LoadingView(title: "Searching")
                } else if viewModel.results.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        resultsList
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, usesSystemSearchBar ? 16 : 96)
        }
        .navigationTitle("Search")
        .task {
            await viewModel.loadFavorites()
        }
    }

    private var resultsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.results) { city in
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(city.displayName)
                                    .font(.headline)
                                Text("Lat \(city.lat), Lon \(city.lon)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if viewModel.isFavorite(city) {
                                Text("Added")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color.green.opacity(0.2)))
                            } else {
                                Button {
                                    Task { await viewModel.addFavorite(from: city) }
                                } label: {
                                    Text("Add")
                                        .foregroundStyle(Color.black)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Capsule().fill(Color.white))
                                }
                               
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            GlassCard {
                VStack(spacing: 8) {
                    Text("Search for a city")
                        .font(.headline)
                    Text("Start typing to find locations and add favorites.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
        }
    }

    private var background: some View {
        LinearGradient(colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2), Color.mint.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }

}

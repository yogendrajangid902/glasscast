// SettingsView.swift
// Settings screen.

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    let userEmail: String

    var body: some View {
        NavigationStack {
            ZStack {
                background
                ScrollView {
                    VStack(spacing: 16) {
                        if !userEmail.isEmpty {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Signed in as")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(userEmail)
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Temperature Unit")
                                    .font(.headline)
                                Picker("Unit", selection: $viewModel.storedUnit) {
                                    Text("Celsius").tag(TemperatureUnit.celsius.rawValue)
                                    Text("Fahrenheit").tag(TemperatureUnit.fahrenheit.rawValue)
                                }
                                .pickerStyle(.segmented)
                            }
                        }

                        GlassCard {
                            Button(role: .destructive) {
                                Task { await viewModel.signOut() }
                            } label: {
                                HStack {
                                    if viewModel.isLoading { ProgressView() }
                                    Text("Sign Out")
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(4)
                            }
                            .buttonStyle(.bordered)
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 96)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var background: some View {
        LinearGradient(colors: [Color.indigo.opacity(0.2), Color.blue.opacity(0.3), Color.mint.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

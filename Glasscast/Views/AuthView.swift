// AuthView.swift
// Login / Sign Up screen.

import SwiftUI

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            background
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Glasscast")
                        .font(.largeTitle.bold())
                    Text("Minimal weather, crystalline UI")
                        .foregroundStyle(.secondary)
                }

                GlassCard {
                    VStack(spacing: 16) {
                        TextField("Email", text: $viewModel.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .padding(12)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.password)
                            .padding(12)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Button(action: {
                            Task { await viewModel.submit() }
                        }, label: {
                            HStack {
                                if viewModel.isLoading { ProgressView() }
                                Text(viewModel.isLogin ? "Log In" : "Create Account")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                        })
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.isValid || viewModel.isLoading)

                        Button(action: { viewModel.isLogin.toggle() }, label: {
                            Text(viewModel.isLogin ? "Need an account? Sign Up" : "Have an account? Log In")
                                .font(.footnote)
                        })
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 60)
        }
        .alert(item: $viewModel.alertItem) { item in
            Alert(
                title: Text("Authentication Error"),
                message: Text(item.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.35), Color.mint.opacity(0.2), Color.cyan.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 240, height: 240)
                .blur(radius: 30)
                .offset(x: -120, y: -200)
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .offset(x: 140, y: 200)
        }
    }
}

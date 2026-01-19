// LoadingView.swift
// Simple loading indicator.

import SwiftUI

struct LoadingView: View {
    let title: String

    var body: some View {
        ZStack {
//            LinearGradient(colors: [Color.blue.opacity(0.25), Color.cyan.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
//                .ignoresSafeArea()
            GlassCard {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(title)
                        .font(.headline)
                }
            }
            .padding(24)
        }
    }
}

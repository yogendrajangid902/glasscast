// GlassCard.swift
// Reusable frosted glass container.

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(GlassBackground())
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct GlassBackground: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
    }
}

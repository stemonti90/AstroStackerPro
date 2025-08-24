//
//  PaywallView.swift
//  AstroStackerPro
//
//  Created by Stefano Monticciolo on 16/08/25.
//


import SwiftUI

/// Paywall minimale compatibile con usi comuni:
/// - `PaywallView()`
/// - `PaywallView(isPresented: $show)`
/// - `PaywallView(isPresented: $show, onPurchased: { ... })`
struct PaywallView: View {
    @Binding var isPresented: Bool
    var onPurchased: (() -> Void)?

    init(isPresented: Binding<Bool> = .constant(false), onPurchased: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.onPurchased = onPurchased
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("AstroStackerPro")
                .font(.largeTitle).bold()
            Text("Unlock pro features")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Label("RAW capture & alignment", systemImage: "sparkles")
                Label("Noise reduction & stacking", systemImage: "star.circle")
                Label("Export & share", systemImage: "square.and.arrow.up")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)

            HStack(spacing: 12) {
                Button("Restore") {
                    // hook futuro per ripristino acquisti
                }
                .buttonStyle(.bordered)

                Button("Upgrade") {
                    onPurchased?()
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Not now") { isPresented = false }
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

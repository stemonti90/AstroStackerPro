//
//  ASPTheme.swift
//  AstroStackerPro
//

import SwiftUI

// MARK: - Design Tokens (compatibili con le chiamate esistenti)
public struct ASPTheme {
    // Brand
    public static let gradient = LinearGradient(colors: [Color.indigo, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
    public static let accent   = Color.indigo
    public static let bg       = Color(UIColor.systemBackground)
    public static let cardBG   = Color(UIColor.secondarySystemBackground)

    // Spacing
    public struct Spacing {
        public static let s:  CGFloat = 8
        public static let m:  CGFloat = 12
        public static let l:  CGFloat = 16
        public static let xl: CGFloat = 24
    }

    // Shape & Shadow
    public struct Shape {
        public static let radius: CGFloat = 20
        public static let smallRadius: CGFloat = 14
        public static let shadowColor = Color.black.opacity(0.12)
        public static let shadowRadius: CGFloat = 20
        public static let shadowY: CGFloat = 10
    }

    // Typography
    public struct Font {
        public static let largeTitle = SwiftUI.Font.system(size: 36, weight: .bold, design: .rounded)
        public static let title      = SwiftUI.Font.title2.weight(.semibold)
    }
}

// MARK: - Header
public struct ASPHeader: View {
    public var title: String
    public var subtitle: String
    public var trailing: AnyView? = nil

    public init(title: String, subtitle: String, trailing: AnyView? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }

    public var body: some View {
        HStack(spacing: ASPTheme.Spacing.l) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(ASPTheme.Font.largeTitle)
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let trailing { trailing }
        }
        .padding(.horizontal, ASPTheme.Spacing.xl)
        .padding(.top, ASPTheme.Spacing.l)
    }
}

// MARK: - Badge
public struct ASPBadge: View {
    public var systemImage: String
    public var text: String
    public init(systemImage: String, text: String) { self.systemImage = systemImage; self.text = text }
    public var body: some View {
        Label(text, systemImage: systemImage)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
    }
}

// MARK: - Primary Button
public struct ASPPrimaryButton: View {
    public var title: String
    public var icon: String? = nil
    public var action: () -> Void
    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title; self.icon = icon; self.action = action
    }
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon) }
                Text(title).font(.headline)
            }
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(ASPTheme.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: ASPTheme.Shape.radius, style: .continuous))
            .shadow(color: ASPTheme.Shape.shadowColor, radius: ASPTheme.Shape.shadowRadius, y: ASPTheme.Shape.shadowY)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Card (title + content closure, compatibile con le chiamate esistenti)
public struct ASPCard<Content: View>: View {
    public var title: String? = nil
    public var subtitle: String? = nil
    @ViewBuilder public var content: Content

    public init(title: String? = nil, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ASPTheme.Spacing.m) {
            if let title { Text(title).font(ASPTheme.Font.title) }
            if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }
            content
        }
        .padding(ASPTheme.Spacing.l)
        .background(ASPTheme.cardBG)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: ASPTheme.Shape.radius, style: .continuous))
        .shadow(color: ASPTheme.Shape.shadowColor, radius: ASPTheme.Shape.shadowRadius, y: ASPTheme.Shape.shadowY)
    }
}

// MARK: - Labeled Slider
public struct ASPLabeledSlider: View {
    public var title: String
    @Binding public var value: Double
    public var range: ClosedRange<Double>
    public var step: Double? = nil
    public var format: String = "%.3f"

    public init(title: String,
                value: Binding<Double>,
                range: ClosedRange<Double>,
                step: Double? = nil,
                format: String = "%.3f") {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.format = format
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Text(String(format: format, value)).font(.subheadline).monospacedDigit()
            }
            if let step { Slider(value: $value, in: range, step: step) }
            else { Slider(value: $value, in: range) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
    }
}

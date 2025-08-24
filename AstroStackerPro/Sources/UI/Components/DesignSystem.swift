import SwiftUI

enum DS {
    static let corner: CGFloat = 16
    static let padding: CGFloat = 16
    static let gridGap: CGFloat = 12

    static let brandGradient = LinearGradient(
        colors: [Color.indigo, Color.purple],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let cardBg = Color(.secondarySystemBackground)
    static let canvasBg = Color(.systemBackground)

    static func sectionTitle(_ text: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage).imageScale(.medium)
            Text(text).font(.headline)
            Spacer(minLength: 0)
        }
        .foregroundStyle(.primary)
    }
}

// Piccolo badge stato
struct StatPill: View {
    var text: String
    var icon: String
    var color: Color = .green

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).imageScale(.small)
            Text(text).font(.caption).bold()
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
}

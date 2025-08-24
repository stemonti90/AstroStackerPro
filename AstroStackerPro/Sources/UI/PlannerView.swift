import SwiftUI

/// The planner view displays a list of upcoming nights and their quality scores.
/// Each list item is presented on a translucent card following the Liquid Glass
/// guidelines.
struct PlannerView: View {
    @EnvironmentObject var planner: PlannerViewModel
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .background(.regularMaterial)
                .ignoresSafeArea()
            List {
                ForEach(planner.nights) { n in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(n.date, style: .date)
                            Spacer()
                            Text(String(format: "%.0f%%", n.score * 100))
                        }
                        .font(.headline)
                        Text(n.note)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .accessibilityLabel(String(format: L("night_of"), n.date.formatted(date: .abbreviated, time: .omitted)))
                }
            }
            .listStyle(.plain)
            .onAppear { planner.refresh() }
            .padding()
            .foregroundColor(.primary)
        }
    }
}
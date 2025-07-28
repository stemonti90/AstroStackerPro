
import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var planner: PlannerViewModel
    var body: some View {
        List(planner.nights) { n in
            VStack(alignment: .leading) {
                HStack {
                    Text(n.date, style: .date)
                    Spacer()
                    Text(String(format: "%.0f%%", n.score*100))
                }
                Text(n.note).font(.caption)
            }
            .accessibilityLabel(String(format: L("night_of"), n.date.formatted(date: .abbreviated, time: .omitted)))
        }
        .onAppear { planner.refresh() }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
        .foregroundColor(Color.primary)
    }
}

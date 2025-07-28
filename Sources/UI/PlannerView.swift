
import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var planner: PlannerViewModel
    var body: some View {
        VStack(spacing: 12) {
            Text("Pianificazione notturna").font(.title2).bold()
            Text("Fase lunare, nuvole, SQM, consigli...")
            List(planner.nights) { night in
                HStack {
                    Text(night.date, style: .date)
                    Spacer()
                    Text(night.scoreLabel)
                }
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .onAppear { planner.refresh() }
    }
}

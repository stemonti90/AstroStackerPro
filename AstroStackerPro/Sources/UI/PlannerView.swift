
import SwiftUI
struct PlannerView: View {
    @EnvironmentObject var planner: PlannerViewModel
    var body: some View {
        VStack(spacing: 12) {
            Text("Pianificazione notturna").font(.title2).bold()
            Text("Fase lunare, nuvole, SQM, consigli...")
            Spacer()
            Text("TODO: UI completa pianificazione")
            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}

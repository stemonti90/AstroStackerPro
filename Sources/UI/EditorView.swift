
import SwiftUI
struct EditorView: View {
    @EnvironmentObject var editorVM: EditorViewModel
    var body: some View {
        VStack(spacing: 12) {
            Text("Editor immagini").font(.title2).bold()
            Text("Curve, HSL, boost stelle...")
            Spacer()
            Text("TODO: UI completa editor")
            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}

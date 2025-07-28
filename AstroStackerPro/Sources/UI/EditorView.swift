
import SwiftUI

struct EditorView: View {
    @EnvironmentObject var editorVM: EditorViewModel
    var body: some View {
        VStack(spacing: 12) {
            Text("Editor immagini").font(.title2).bold()
            if let img = editorVM.preview {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel("Anteprima immagine")
            } else {
                Text("Nessuna immagine in modifica")
            }
            Slider(value: $editorVM.exposure, in: -1...1) { Text("Exposure") }
                .accessibilityLabel("Regola esposizione")
            Slider(value: $editorVM.contrast, in: -1...1) { Text("Contrast") }
                .accessibilityLabel("Regola contrasto")
            Toggle("Boost Stelle", isOn: $editorVM.starBoost)
                .accessibilityLabel("Aumenta luminosit\u00e0 stelle")
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
        .foregroundColor(Color.primary)
    }
}

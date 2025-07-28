
import SwiftUI

struct EditorView: View {
    @EnvironmentObject var editorVM: EditorViewModel
    var body: some View {
        VStack(spacing: 12) {
            Text("Editor immagini").font(.title2).bold()
            if let img = editorVM.preview {
                Image(uiImage: img).resizable().scaledToFit()
            } else {
                Text("Nessuna immagine in modifica")
            }
            Slider(value: $editorVM.exposure, in: -1...1) { Text("Exposure") }
            Slider(value: $editorVM.contrast, in: -1...1) { Text("Contrast") }
            Toggle("Boost Stelle", isOn: $editorVM.starBoost)
            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}

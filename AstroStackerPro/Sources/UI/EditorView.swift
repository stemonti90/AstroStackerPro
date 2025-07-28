
import SwiftUI

struct EditorView: View {
    @EnvironmentObject var editorVM: EditorViewModel
    var body: some View {
        VStack(spacing: 12) {
            Text(L("image_editor")).font(.title2).bold()
            if let img = editorVM.preview {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(L("image_editor"))
            } else {
                Text(L("no_edit_image"))
            }
            Slider(value: $editorVM.exposure, in: -1...1) { Text(L("exposure")) }
                .accessibilityLabel(L("exposure"))
            Slider(value: $editorVM.contrast, in: -1...1) { Text(L("contrast")) }
                .accessibilityLabel(L("contrast"))
            Toggle(L("star_boost"), isOn: $editorVM.starBoost)
                .accessibilityLabel(L("star_boost"))
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
        .foregroundColor(Color.primary)
    }
}

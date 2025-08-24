import SwiftUI

/// The editor view allows users to adjust exposure, contrast and other parameters
/// on the processed image.  It adopts the Liquid Glass aesthetic with
/// translucent panels and rounded corners.
struct EditorView: View {
    @EnvironmentObject var editorVM: EditorViewModel
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .background(.regularMaterial)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text(L("image_editor"))
                    .font(.title2)
                    .bold()
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Group {
                    if let img = editorVM.preview {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                            .shadow(radius: 8, y: 4)
                            .accessibilityLabel(L("image_editor"))
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 200)
                            .overlay(Text(L("no_edit_image")).foregroundColor(.secondary))
                    }
                }
                VStack(spacing: 12) {
                    Text(L("exposure"))
                    Slider(value: $editorVM.exposure, in: -1...1)
                        .tint(.orange)
                    Text(L("contrast"))
                    Slider(value: $editorVM.contrast, in: -1...1)
                        .tint(.yellow)
                    Toggle(L("star_boost"), isOn: $editorVM.starBoost)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Spacer()
            }
            .padding()
            .foregroundColor(.primary)
        }
    }
}
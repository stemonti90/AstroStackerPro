//
//  EditorScreen.swift
//  AstroStackerPro
//

import SwiftUI
import CoreImage

struct EditorScreen: View {
    @EnvironmentObject var services: AppServices
    @ObservedObject private var pipeline: StackingPipeline = .shared
    private let ciContext = CIContext()

    var body: some View {
        ScrollView {
            ASPHeader(title: "Editor", subtitle: "Rifinisci lo stack")
                .padding(.bottom, 4)

            VStack(spacing: ASPTheme.Spacing.xl) {
                ASPCard(title: "Anteprima") {
                    if let image = pipeline.lastResult,
                       let cg = ciContext.createCGImage(image, from: image.extent) {
                        Image(decorative: cg, scale: 1.0)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: ASPTheme.Shape.smallRadius))
                    } else {
                        RoundedRectangle(cornerRadius: ASPTheme.Shape.smallRadius)
                            .fill(.black.opacity(0.85))
                            .frame(height: 220)
                            .overlay(Text("Nessuna immagine").foregroundStyle(.white.opacity(0.6)))
                    }
                }

                ASPCard(title: "Regolazioni") {
                    ASPLabeledSlider(title: "AI Denoise",
                                     value: $services.editor.denoise,
                                     range: 0...1, step: 0.01)
                    ASPLabeledSlider(title: "Nitidezza",
                                     value: $services.editor.sharpen,
                                     range: 0...1, step: 0.01)
                    ASPLabeledSlider(title: "Saturazione",
                                     value: $services.editor.saturation,
                                     range: 0.5...2, step: 0.01)
                }

                ASPPrimaryButton(title: "Esporta", icon: "square.and.arrow.up") {
                    Task {
                        guard let img = pipeline.lastResult else { return }
                        let adjusted = services.editor.applyAdjustments(to: img)
                        StackingPipeline.shared.exportToPhotos(ciImage: adjusted)
                    }
                }
            }
            .padding(.horizontal, ASPTheme.Spacing.xl)
            .padding(.bottom, ASPTheme.Spacing.xl)
        }
        .background(ASPTheme.bg)
    }
}

//
//  GalleryView.swift
//  AstroStackerPro
//

import SwiftUI
import CoreImage
import UIKit

struct GalleryView: View {
    // Tipo esplicito: evita “shared cannot be resolved without contextual type”
    @ObservedObject private var pipeline: StackingPipeline = .shared
    @State private var uiImage: UIImage?
    @State private var showShare = false

    var body: some View {
        VStack(spacing: ASPTheme.Spacing.m) {

            ASPHeader(title: "Galleria", subtitle: "Ultimo Stack")

            if let result = pipeline.lastResult,
               let cg = CIContext().createCGImage(result, from: result.extent) {
                let img = UIImage(cgImage: cg)
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .padding(.horizontal, ASPTheme.Spacing.l)
                    .onAppear { uiImage = img }
            } else {
                Text("Nessuna immagine disponibile")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let img = uiImage {
                HStack(spacing: ASPTheme.Spacing.m) {
                    ASPPrimaryButton(title: "Denoise") {
                        uiImage = AIDenoiser.shared.denoise(uiImage: img,
                                                            noiseLevel: 0.35,
                                                            sharpness: 0.4)
                    }
                    ASPPrimaryButton(title: "Salva") {
                        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                    }
                    ASPPrimaryButton(title: "Condividi") {
                        showShare = true
                    }
                }
                .padding(.horizontal, ASPTheme.Spacing.l)
            }
        }
        .sheet(isPresented: $showShare) {
            if let img = uiImage { ShareSheet(activityItems: [img]) }
        }
    }
}

// Share sheet helper
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

import SwiftUI
import AVFoundation

struct CaptureScreen: View {
    @EnvironmentObject var services: AppServices

    var body: some View {
        ScrollView {
            header
            VStack(spacing: ASPTheme.Spacing.xl) {
                ASPCard(title: "Anteprima") {
                    livePreview
                    HStack(spacing: 8) {
                        ASPBadge(systemImage: "dot.radiowaves.left.and.right",
                                 text: services.capture.isRecording ? "REC" : "Pronto")
                        ASPBadge(systemImage: "bolt", text: services.capture.useProRAW ? "RAW" : "HEIF")
                        Spacer()
                    }
                }

                ASPCard(title: "Parametri di cattura") {
                    ASPLabeledSlider(title: "Tempo esposizione (s)",
                                     value: $services.capture.exposure,
                                     range: 1...60, step: 1, format: "%.0f s")
                    ASPLabeledSlider(title: "ISO",
                                     value: $services.capture.iso,
                                     range: 100...6400, step: 100, format: "%.0f")
                    ASPLabeledSlider(title: "Frame da acquisire",
                                     value: Binding(
                                        get: { Double(services.capture.frames) },
                                        set: { services.capture.frames = Int($0) }),
                                     range: 1...200, step: 1, format: "%.0f")
                }

                HStack(spacing: ASPTheme.Spacing.l) {
                    ASPPrimaryButton(
                        title: services.capture.isRecording ? "In acquisizione…" : "Start",
                        icon: services.capture.isRecording ? "stop.fill" : "record.circle"
                    ) {
                        if services.capture.isRecording {
                            services.capture.stop()
                        } else {
                            services.capture.start()
                        }
                    }
                    Button {
                        services.capture.useProRAW.toggle()
                    } label: {
                        Text("RAW")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: ASPTheme.Shape.radius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, ASPTheme.Spacing.xl)
            .padding(.bottom, ASPTheme.Spacing.xl)
        }
        .background(ASPTheme.bg)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Unica chiamata sicura: configura E avvia (startRunning dopo il commit)
            services.captureManager.configureAndStartIfNeeded()
        }
    }

    private var header: some View {
        ASPHeader(
            title: "AstroStackerPro",
            subtitle: "Cattura RAW • Allinea • Stack • Migliora",
            trailing: AnyView(
                Button(action: {}) {
                    Image(systemName: "sparkles")
                        .imageScale(.large)
                        .padding(12)
                        .background(ASPTheme.gradient, in: Circle())
                        .foregroundStyle(.white)
                }
            )
        )
        .padding(.bottom, 4)
    }

    private var livePreview: some View {
        CameraPreviewView(session: services.captureManager.sessionForPreview)
            .clipShape(RoundedRectangle(cornerRadius: ASPTheme.Shape.smallRadius))
            .frame(height: 240)
    }
}

// UIKit wrapper per l’anteprima
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = v.bounds
        v.layer.addSublayer(layer)
        context.coordinator.layer = layer
        return v
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.layer?.frame = uiView.bounds
    }
    func makeCoordinator() -> Coord { Coord() }
    final class Coord { var layer: AVCaptureVideoPreviewLayer? }
}

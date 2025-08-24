//
//  RAWCaptureSheet.swift
//  AstroStackerPro
//
//  Foglio per avviare rapidamente una sequenza di scatto RAW/HEIF
//

import SwiftUI

struct RAWCaptureSheet: View {
    @EnvironmentObject var services: AppServices
    @Environment(\.dismiss) private var dismiss

    // Impostazioni locali (copiate/propagate al bridge quando si preme "Avvia")
    @State private var frames: Double = 10
    @State private var exposure: Double = 4
    @State private var iso: Double = 800
    @State private var useProRAW: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Formato") {
                    Toggle("Usa Apple ProRAW (se disponibile)", isOn: $useProRAW)
                }

                Section("Parametri di scatto") {
                    HStack {
                        Text("Tempo (s)")
                        Spacer()
                        Text("\(Int(exposure)) s").foregroundStyle(.secondary)
                    }
                    Slider(value: $exposure, in: 1...60, step: 1)

                    HStack {
                        Text("ISO")
                        Spacer()
                        Text("\(Int(iso))").foregroundStyle(.secondary)
                    }
                    Slider(value: $iso, in: 100...6400, step: 100)

                    HStack {
                        Text("Frame")
                        Spacer()
                        Text("\(Int(frames))").foregroundStyle(.secondary)
                    }
                    Slider(value: $frames, in: 1...200, step: 1)
                }

                Section {
                    Button {
                        // Propaga al bridge e avvia
                        services.capture.useProRAW = useProRAW
                        services.capture.exposure = exposure
                        services.capture.iso = iso
                        services.capture.frames = Int(frames)
                        services.capture.start()
                        dismiss()
                    } label: {
                        Label("Avvia sequenza", systemImage: "record.circle")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)

                    if services.capture.isRecording {
                        Button(role: .destructive) {
                            services.capture.stop()
                        } label: {
                            Label("Interrompi", systemImage: "stop.fill")
                        }
                    }
                }
            }
            .navigationTitle("Cattura RAW")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Chiudi") { dismiss() }
                }
            }
            .onAppear {
                // Allinea i controlli con lo stato corrente del bridge
                useProRAW = services.capture.useProRAW
                exposure = services.capture.exposure
                iso = services.capture.iso
                frames = Double(services.capture.frames)
            }
        }
    }
}


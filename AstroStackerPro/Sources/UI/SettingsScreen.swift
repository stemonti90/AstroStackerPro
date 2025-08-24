import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var services: AppServices

    @AppStorage("asp.useProRAW") private var useProRAW: Bool = true
    @AppStorage("asp.themeAuto") private var themeAuto: Bool = true
    @AppStorage("asp.saveLocalStacks") private var saveLocalStacks: Bool = true

    @State private var appVersion: String = "-"
    @State private var buildNumber: String = "-"

    var body: some View {
        List {
            Section("Acquisizione") {
                Toggle("Usa Apple ProRAW (se disponibile)", isOn: $useProRAW)
                    .onChange(of: useProRAW, initial: false) { _, newValue in
                        // Aggiorna la proprietà del bridge (no singleton)
                        services.capture.useProRAW = newValue
                    }

                Toggle("Salva stack localmente (Documents)", isOn: $saveLocalStacks)
                    .onChange(of: saveLocalStacks, initial: false) { _, on in
                        if !on {
                            print("⚠️ Hai disattivato il salvataggio locale (aggiungi un guard in pipeline).")
                        }
                    }
            }

            Section("Aspetto") {
                Toggle("Tema automatico (iOS)", isOn: $themeAuto)
                if !themeAuto {
                    HStack {
                        Text("Tema")
                        Spacer()
                        Text("Chiaro / Scuro")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Info") {
                HStack { Text("Versione"); Spacer(); Text(appVersion).foregroundStyle(.secondary) }
                HStack { Text("Build"); Spacer(); Text(buildNumber).foregroundStyle(.secondary) }
            }
        }
        .navigationTitle("Impostazioni")
        .onAppear(perform: loadAppInfo)
    }

    private func loadAppInfo() {
        let dict = Bundle.main.infoDictionary
        appVersion = dict?["CFBundleShortVersionString"] as? String ?? "-"
        buildNumber = dict?["CFBundleVersion"] as? String ?? "-"
    }
}


import SwiftUI

struct CalibrationWizardView: View {
    @EnvironmentObject var captureManager: AstroCaptureManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text(L("calibration_title")).font(.title2).bold()
                Text(L("calibration_desc"))
                    .multilineTextAlignment(.center)

                Button(L("capture_dark")) { captureManager.captureCalibration(.dark, seconds: 3) }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel(L("capture_dark"))
                Button(L("capture_flat")) { captureManager.captureCalibration(.flat, seconds: 3) }
                    .accessibilityLabel(L("capture_flat"))
                Button(L("capture_bias")) { captureManager.captureCalibration(.bias, seconds: 0) }
                    .accessibilityLabel(L("capture_bias"))

                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button(L("close")) { dismiss() })
        }
    }
}

//
//  LabeledSlider.swift
//  AstroStackerPro
//
//  Created by Stefano Monticciolo on 09/08/25.
//


import SwiftUI

struct LabeledSlider: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double? = nil
    var format: String = "%.3f"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Text(String(format: format, value)).font(.subheadline).monospacedDigit()
            }
            if let step {
                Slider(value: $value, in: range, step: step)
            } else {
                Slider(value: $value, in: range)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
    }
}

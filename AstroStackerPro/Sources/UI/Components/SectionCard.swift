//
//  SectionCard.swift
//  AstroStackerPro
//
//  Created by Stefano Monticciolo on 09/08/25.
//


import SwiftUI

struct SectionCard<Content: View>: View {
    var title: String
    var systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DS.gridGap) {
            DS.sectionTitle(title, systemImage: systemImage)
            content
        }
        .padding(DS.padding)
        .background(DS.cardBg, in: RoundedRectangle(cornerRadius: DS.corner, style: .continuous))
    }
}

//
//  File.swift
//
//
//  Created by Tom Knighton on 10/09/2023.
//

import SwiftUI

struct SnudownQuoteView: View {

    @Environment(\.snuTextAlignment) var textAlignment: Alignment
    @Environment(\.snuMultilineTextAlignment) var snuMultilineAlignment: TextAlignment

    let quote: SnuQuoteBlockNode

    var body: some View {
        VStack {
            ForEach(quote.children, id: \.id) { child in
                SnudownRenderSwitch(node: child)
                    .frame(maxWidth: .infinity, alignment: textAlignment)
                    .multilineTextAlignment(snuMultilineAlignment)
            }
        }
        .opacity(0.65)
        .italic()
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .overlay(alignment: .leading) {
            Color(.systemGray)
                .frame(width: 4)
        }
    }
}

#Preview {
    SnudownView(
        text: """
            >This is a quoted text

            With normal text underneath
            """
    )
}

//
//  File.swift
//
//
//  Created by Tom Knighton on 10/09/2023.
//

import SwiftUI

struct SnudownSpoilerView: View {

    @Environment(\.snuDefaultFont) var defaultFont: Font
    @State private var isOpen: Bool = false

    let node: SnuSpoilerNode
    
    @Namespace var transition

    var body: some View {
        Group {
            if isOpen {
                text()
            } else {
                Text("SPOILER")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background {
            Color(isOpen ? .systemGray6 : .systemGray2).clipShape(.rect(cornerRadius: 8))
        }
        .matchedGeometryEffect(id: "spoiler", in: transition, anchor: .leading)
        .onTapGesture {
            withAnimation {
                isOpen.toggle()
            }
        }
    }

    @ViewBuilder
    func text() -> some View {
        let children = node.children.filter { $0 is SnuTextNode }.compactMap { $0 as? SnuTextNode }
        if children.count > 0 {
            let parent = SnuTextNode(insideText: "", children: children)
            SnudownTextView(node: parent)
        } else {
            Text(node.insideText)
                .font(defaultFont)
        }
    }
}

#Preview {
    SnudownSpoilerView(
        node: SnuSpoilerNode(
            insideText: "This is hidden spoiler content that will be revealed when tapped",
            children: [
                SnuTextNode(insideText: "Secret information here!", children: [])
            ]
        )
    )
    .padding()
}

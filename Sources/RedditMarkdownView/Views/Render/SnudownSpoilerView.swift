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

    var body: some View {
        Group {
            if isOpen {
                text()
            } else {
                Text("SPOILER")
                    .font(.caption)
            }
        }
        .padding(.all, 4)
        .background {
            Color(isOpen ? .systemGray6 : .systemGray2).clipShape(.rect(cornerRadius: 10))
        }
        .overlay {
            if !isOpen {
                Text("SPOILER")
                    .foregroundStyle(.white)
                    .font(.caption)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
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

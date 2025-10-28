//
//  SnudownTextView.swift
//
//
//  Created by Tom Knighton on 10/09/2023.
//

import Nuke
import SwiftUI
import UIKit
import Zoomable

struct SnudownTextView: View {

    @Environment(\.snuDefaultFont) var defaultFont: Font
    @Environment(\.snuTextColour) private var textColor
    @Environment(\.snuLinkColour) private var linkColor
    @Environment(\.snuDisplayInlineImages) private var displayImages
    @Environment(\.snuInlineImageWidth) private var imageWidth
    @Environment(\.snuInlineImageShowLink) private var showInlineImageLinks

    let node: SnuTextNode

    private var font: Font?

    init(node: SnuTextNode, font: Font? = nil) {
        self.node = node
        self.font = font
    }

    var body: some View {
        buildView(for: node)
            .foregroundColor(textColor)
            .tint(linkColor)
    }

    private func buildView(for node: SnuTextNode) -> AnyView {
        if let link = node as? SnuLinkNode {
            let linkHref = link.linkHref.trimmingCharacters(in: .whitespacesAndNewlines)
            if displayImages, URL(string: linkHref) != nil {
                return AnyView(
                    InlineRemoteImageView(
                        urlString: linkHref,
                        imageWidth: imageWidth,
                        showLink: showInlineImageLinks,
                        linkText: link.contentAsCMarkString()
                    )
                    .font(font ?? defaultFont)
                )
            } else {
                return AnyView(
                    Text(link.contentAsCMarkString())
                        .font(font ?? defaultFont)
                )
            }
        }

        let childNodes = node.children.filter { $0 is SnuTextNode }.compactMap { $0 as? SnuTextNode }

        if childNodes.count > 0 {
            return AnyView(buildChildrenViews(childNodes))
        } else {
            return AnyView(
                buildTextOnly(for: node)
                    .snuTextDecoration(node.decoration, font: font ?? defaultFont)
            )
        }
    }

    private func buildTextOnly(for node: SnuTextNode) -> Text {
        var textToDisplay = node.insideText
        if textToDisplay.hasSuffix("\n") {
            textToDisplay = String(textToDisplay.dropLast())
        }
        return Text(textToDisplay)
            .font(font ?? defaultFont)
    }

    private func buildChildrenViews(_ children: [SnuTextNode]) -> some View {
        var views: [AnyView] = []
        var currentText = Text("")
        var hasAccumulatedText = false

        func flushText() {
            if hasAccumulatedText {
                views.append(AnyView(currentText))
                currentText = Text("")
                hasAccumulatedText = false
            }
        }

        for child in children {
            if let link = child as? SnuLinkNode {
                flushText()
                let linkHref = link.linkHref.trimmingCharacters(in: .whitespacesAndNewlines)
                if displayImages, URL(string: linkHref) != nil {
                    let view = InlineRemoteImageView(
                        urlString: linkHref,
                        imageWidth: imageWidth,
                        showLink: showInlineImageLinks,
                        linkText: link.contentAsCMarkString()
                    )
                    views.append(AnyView(view))
                } else {
                    let linkText = Text(link.contentAsCMarkString()).font(font ?? defaultFont)
                    views.append(AnyView(linkText))
                }
            } else {
                let piece = buildTextOnly(for: child)
                    .snuTextDecoration(child.decoration, font: font ?? defaultFont)
                currentText = hasAccumulatedText ? (currentText + piece) : piece
                hasAccumulatedText = true
            }
        }

        flushText()

        return VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(views.indices), id: \.self) { idx in
                views[idx]
            }
        }
    }
}

extension Text {

    func snuTextDecoration(_ decoration: SnuTextNodeDecoration?, font: Font?) -> Text {
        var toReturn = self
        if let font {
            toReturn = toReturn.font(font)
        }
        switch decoration {
        case .bold:
            return toReturn.bold()
        case .italic:
            return toReturn.italic()
        case .strikethrough:
            return toReturn.strikethrough()
        case .none:
            return toReturn
        }
    }
}

extension SnuTextNode {

    func contentAsCMarkString() -> String {
        var result = buildAttributedString(node: self)

        if let link = self as? SnuLinkNode {
            result = "[\(result)](\(link.linkHref.trimmingCharacters(in: .whitespacesAndNewlines)))"
        }

        return result
    }

    private func buildAttributedString(node: SnuTextNode) -> String {
        var result = ""

        for child in node.children.compactMap({ $0 as? SnuTextNode }) {
            var childAttributed = child.insideText
            childAttributed.append(buildAttributedString(node: child))
            switch child.decoration {
            case .bold:
                result.append("**\(childAttributed)**")
            case .italic:
                result.append("*\(childAttributed)*")
            case .strikethrough:
                result.append("~~\(childAttributed)~~")
            default:
                result.append("\(childAttributed)")
            }
        }

        return result
    }
}

struct InlineRemoteImageView: View {
    let urlString: String
    let imageWidth: CGFloat
    let showLink: Bool
    let linkText: String

    @State private var uiImage: UIImage? = nil

    @State private var isPresenting: Bool = false
    @Namespace var zoomNamespace

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 300)
                    .clipShape(.rect(cornerRadius: 15, style: .continuous))
                    .clipped()
                    .contentShape(.rect)
                    .matchedTransitionSource(id: "image", in: zoomNamespace)
                    .highPriorityGesture(
                        TapGesture()
                            .onEnded {
                                withAnimation {
                                    isPresenting = true
                                }
                            }
                    )
            }
            if showLink {
                Text(LocalizedStringKey(linkText))
            }
        }
        .task(id: urlString) {
            await loadImage()
        }
        .fullScreenCover(isPresented: $isPresenting) {
            ZStack {
                Color.black
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .zoomable()
                }
            }
            .ignoresSafeArea()

            .overlay {
                HStack {
                    Button {
                        withAnimation {
                            isPresenting = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.ultraThinMaterial)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
            }
            .navigationTransition(.zoom(sourceID: "image", in: zoomNamespace))
        }
    }

    @MainActor
    private func setImage(_ image: UIImage?) {
        self.uiImage = image
    }

    private func loadImage() async {
        guard let url = URL(string: urlString) else { return }
        let request = ImageRequest(url: url)
        do {
            let image: UIImage = try await ImagePipeline.shared.image(for: request)
            setImage(image)
        } catch {
            // Ignore errors; fallback is to show link text only
        }
    }
}

#Preview {
    let exampleMarkdown = """
        ### Inline Images
        https://preview.redd.it/qetjx552lexf1.jpg?width=4032&format=pjpg&auto=webp&s=34de6999384a65b0a300d5072f5e4626f68b12c2

        https://preview.redd.it/240hy852lexf1.jpg?width=4284&format=pjpg&auto=webp&s=b8689a963b75ba2ebd5f730a17c3f97034703b83

        ### Plain Text
        Upgraded from a 2014 intel MacBook Pro that sounds like a jet engine when web browsing and a battery that lasted 90 minutes. Holy cow, what a quantum leap these machines have come.

        ### Link with Title
        [Some Link](https://www.radobley.com)

        ### Code
        `This is inline code`

        ```
        import SwiftUI\nstruct Snudown: View {\nvar body: some View {\n// code goes here\n}\n}
        ```

        ### Spoiler
        This is a >!spoiler content which should be hidden!<

        ### Quote
        > this is a quoted content
        with unquoted content as well

        ### List
        ##### Ordered
        1. Item 1
        2. Item 2
        3. Item 3

        ##### Unordered
        * Item 1
        * Item 2
        * Item 3
        """
    ScrollView {
        SnudownView(text: exampleMarkdown)
    }
    .padding(.horizontal, 8)
    .background { Color(uiColor: .tertiarySystemBackground).ignoresSafeArea() }
}

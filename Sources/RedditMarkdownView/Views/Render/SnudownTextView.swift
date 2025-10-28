//
//  SnudownTextView.swift
//
//
//  Created by Tom Knighton on 10/09/2023.
//

import Nuke
import SwiftUI

struct SnudownTextView: View {

    @Environment(\.snuDefaultFont) var defaultFont: Font
    @Environment(\.snuTextColour) private var textColor
    @Environment(\.snuLinkColour) private var linkColor
    @Environment(\.snuDisplayInlineImages) private var displayImages
    @Environment(\.snuInlineImageWidth) private var imageWidth
    @Environment(\.snuInlineImageShowLink) private var showInlineImageLinks

    @State private var result: Text? = nil

    let node: SnuTextNode

    private var font: Font?

    init(node: SnuTextNode, font: Font? = nil) {
        self.node = node
        self.font = font
    }

    var body: some View {
        buildTextView(for: node)
            .foregroundColor(textColor)
            .tint(linkColor)
    }

    private func buildTextView(for node: SnuTextNode) -> Text {
        if let link = node as? SnuLinkNode {
            return link.contentAsCMark(
                loadImages: displayImages,
                imageWidth: imageWidth,
                showLink: showInlineImageLinks
            )
            .font(font ?? defaultFont)
        }

        let childNodes = node.children.filter { $0 is SnuTextNode }.compactMap { $0 as? SnuTextNode }

        if childNodes.count > 0 {
            return buildChildrenTextViews(childNodes)
                .snuTextDecoration(node.decoration, font: font ?? defaultFont)
        } else {
            var textToDisplay = node.insideText
            if textToDisplay.hasSuffix("\n") {
                textToDisplay = String(textToDisplay.dropLast())
            }
            return Text(textToDisplay)
                .snuTextDecoration(node.decoration, font: font ?? defaultFont)
        }
    }

    private func buildChildrenTextViews(_ children: [SnuTextNode]) -> Text {
        return children.asyncReduce(Text("")) { (result, childNode) in
            result
                + (buildTextView(for: childNode)
                    .snuTextDecoration(childNode.decoration, font: font ?? defaultFont))
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

    func contentAsCMark(loadImages: Bool, imageWidth: CGFloat, showLink: Bool) -> Text {

        var result = buildAttributedString(node: self)

        if let link = self as? SnuLinkNode {

            result = "[\(result)](\(link.linkHref.trimmingCharacters(in: .whitespacesAndNewlines)))"

            if loadImages, let linkUrl = URL(string: link.linkHref.trimmingCharacters(in: .whitespacesAndNewlines)) {
                let imageTask: Task<Text?, Never> = Task.detached(priority: .background) { [result] in
                    let request = ImageRequest(
                        url: linkUrl,
                        processors: [.resize(width: imageWidth)]
                    )
                    let imageTask = try? await ImagePipeline.shared.image(for: request)
                    if let cgImage = await imageTask?.byPreparingForDisplay() {
                        var returnText = Text(Image(uiImage: cgImage).resizable())
                        if showLink {
                            returnText = returnText + Text("\n") + Text(LocalizedStringKey(result))
                        }
                        return returnText
                    }

                    return nil
                }

                Task {
                    if let value = await imageTask.value {
                        return value
                    }
                    return Text("")
                }
            }

        }

        return Text(LocalizedStringKey(result))
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

extension Sequence {
    public func asyncReduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: ((Result, Element) throws -> Result)
    ) rethrows -> Result {
        var result = initialResult
        for element in self {
            result = try nextPartialResult(result, element)
        }
        return result
    }
}

#Preview {
    let exampleMarkdown = """
        ### Inline Images
        https://preview.redd.it/qetjx552lexf1.jpg?width=4032&format=pjpg&auto=webp&s=34de6999384a65b0a300d5072f5e4626f68b12c2

        https://preview.redd.it/240hy852lexf1.jpg?width=4284&format=pjpg&auto=webp&s=b8689a963b75ba2ebd5f730a17c3f97034703b83

        ### Plain Text
        Upgraded from a 2014 intel MacBook Pro that sounds like a jet engine when web browsing and a battery that lasted 90 minutes. Holy cow, what a quantum leap these machines have come.

        ### Text Styles
        This is **bold text**
        This is *italic text*
        This is ***bold italic text***
        This is ~~Strikethrough text~~
        This is a ^(superscript)

        ### Link with Title
        [Some Link](https://www.radobley.com)

        ### Code
        `This is inline code`


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
}

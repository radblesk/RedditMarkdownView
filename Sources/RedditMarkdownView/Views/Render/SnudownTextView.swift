//
//  SnudownTextView.swift
//

import SwiftUI
import Nuke
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
    
    // MARK: - Builders (sync text, async images)
    
    private func buildView(for node: SnuTextNode) -> AnyView {
        // Links: render as image if URL is an image; otherwise render link text
        if let link = node as? SnuLinkNode {
            let href = link.linkHref.trimmingCharacters(in: .whitespacesAndNewlines)
            if displayImages, isImageURL(href) {
                return AnyView(
                    InlineRemoteImageView(
                        urlString: href,
                        imageWidth: imageWidth,
                        showLink: showInlineImageLinks,
                        linkText: link.contentAsCMarkString()
                    )
                    .font(font ?? defaultFont)
                )
            } else {
                return AnyView(
                    link.contentAsCMark(loadImages: false, imageWidth: imageWidth, showLink: showInlineImageLinks)
                        .font(font ?? defaultFont)
                )
            }
        }
        
        let childNodes = node.children.compactMap { $0 as? SnuTextNode }
        
        if childNodes.isEmpty {
            var t = node.insideText
            if t.hasSuffix("\n") { t.removeLast() }
            return AnyView(
                Text(t)
                    .snuTextDecoration(node.decoration, font: font ?? defaultFont)
                    .font(font ?? defaultFont)
            )
        } else {
            // If no image links anywhere, build a single Text for perfect wrapping.
            let hasImage = displayImages && childNodes.contains { n in
                guard let l = n as? SnuLinkNode else { return false }
                return isImageURL(l.linkHref.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            if !hasImage {
                let text: Text = childNodes.reduce(Text("")) { acc, child in
                    let piece = buildText(for: child).snuTextDecoration(child.decoration, font: font ?? defaultFont)
                    return Text("\(acc)\(piece)")
                }
                return AnyView(
                    text
                        .snuTextDecoration(node.decoration, font: font ?? defaultFont)
                        .font(font ?? defaultFont)
                )
            }
            
            // Mixed path: interleave image views and collapsed text segments.
            var segments: [AnyView] = []
            var buffer: [Text] = []
            
            func flushBuffer() {
                guard buffer.isEmpty == false else { return }
                let combined = buffer.dropFirst().reduce(buffer.first ?? Text("")) { acc, nxt in
                    Text("\(acc)\(nxt)")
                }
                segments.append(AnyView(combined.font(font ?? defaultFont)))
                buffer.removeAll(keepingCapacity: true)
            }
            
            for child in childNodes {
                if let link = child as? SnuLinkNode {
                    let href = link.linkHref.trimmingCharacters(in: .whitespacesAndNewlines)
                    if displayImages, isImageURL(href) {
                        flushBuffer()
                        segments.append(AnyView(
                            InlineRemoteImageView(
                                urlString: href,
                                imageWidth: imageWidth,
                                showLink: showInlineImageLinks,
                                linkText: link.contentAsCMarkString()
                            )
                            .font(font ?? defaultFont)
                        ))
                        continue
                    }
                }
                let piece = buildText(for: child).snuTextDecoration(child.decoration, font: font ?? defaultFont)
                buffer.append(piece)
            }
            flushBuffer()
            
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(segments.indices, id: \.self) { i in
                        segments[i]
                    }
                }
                    .snuTextDecoratedView(node.decoration, font: font ?? defaultFont)
            )
        }
    }
    
    private func buildText(for node: SnuTextNode) -> Text {
        if let link = node as? SnuLinkNode {
            return link.contentAsCMark(loadImages: false, imageWidth: imageWidth, showLink: showInlineImageLinks)
                .font(font ?? defaultFont)
        }
        let children = node.children.compactMap { $0 as? SnuTextNode }
        if children.isEmpty {
            var t = node.insideText
            if t.hasSuffix("\n") { t.removeLast() }
            return Text(t).font(font ?? defaultFont)
        } else {
            return children.reduce(Text("")) { acc, child in
                let piece = buildText(for: child).snuTextDecoration(child.decoration, font: font ?? defaultFont)
                return Text("\(acc)\(piece)")
            }
            .font(font ?? defaultFont)
        }
    }
    
    // MARK: - Image URL detection
    
    private func isImageURL(_ href: String) -> Bool {
        guard let url = URL(string: href), let host = url.host?.lowercased() else { return false }
        let path = url.path.lowercased()
        if path.hasSuffix(".jpg") || path.hasSuffix(".jpeg") || path.hasSuffix(".png") || path.hasSuffix(".gif") || path.hasSuffix(".webp") {
            return true
        }
        // Reddit image hosts often omit extensions
        if host.contains("i.redd.it") || host.contains("preview.redd.it") { return true }
        return false
    }
}

// MARK: - Text decorations

extension Text {
    func snuTextDecoration(_ decoration: SnuTextNodeDecoration?, font: Font?) -> Text {
        var t = self
        if let font { t = t.font(font) }
        switch decoration {
        case .bold:          return t.bold()
        case .italic:        return t.italic()
        case .strikethrough: return t.strikethrough()
        case .none:          return t
        }
    }
}

// Apply decoration to AnyView trees (for parent node decoration)
private extension View {
    func snuTextDecoratedView(_ decoration: SnuTextNodeDecoration?, font: Font?) -> AnyView {
        switch decoration {
        case .bold:          return AnyView(self.bold().font(font))
        case .italic:        return AnyView(self.italic().font(font))
        case .strikethrough: return AnyView(self.strikethrough().font(font))
        case .none:          return AnyView(self.font(font))
        }
    }
}

// MARK: - Node helpers (original-safe)

extension SnuTextNode {
    // Markdown text only; images handled by view layer
    func contentAsCMark(loadImages: Bool, imageWidth: CGFloat, showLink: Bool) -> Text {
        var result = buildAttributedString(node: self)
        if let link = self as? SnuLinkNode {
            result = "[\(result)](\(link.linkHref.trimmingCharacters(in: .whitespacesAndNewlines)))"
        }
        return Text(LocalizedStringKey(result))
    }
    
    func contentAsCMarkString() -> String {
        var result = buildAttributedString(node: self)
        if let link = self as? SnuLinkNode {
            result = "[\(result)](\(link.linkHref.trimmingCharacters(in: .whitespacesAndNewlines)))"
        }
        return result
    }
    
    fileprivate func buildAttributedString(node: SnuTextNode) -> String {
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

// MARK: - Inline image view (async fetch)

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
                        TapGesture().onEnded { withAnimation { isPresenting = true } }
                    )
                
                if showLink {
                    Text(LocalizedStringKey(linkText))
                }
            } else {
                // Text is already rendered above; while loading, keep layout stable with caption if desired
                if showLink {
                    Text(LocalizedStringKey(linkText))
                }
            }
        }
        .task(id: urlString) { await loadImage() }
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
                        withAnimation { isPresenting = false }
                    } label: {
                        Image(systemName: "xmark")
                            .padding(12)
                            .foregroundStyle(.secondary)
                            .clipShape(.circle)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: .circle)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
            }
            .navigationTransition(.zoom(sourceID: "image", in: zoomNamespace))
        }
    }
    
    @MainActor
    private func setImage(_ image: UIImage?) { self.uiImage = image }
    
    private func loadImage() async {
        guard let url = URL(string: urlString) else { return }
        let request = ImageRequest(url: url)
        do {
            let image: UIImage = try await ImagePipeline.shared.image(for: request)
            setImage(image)
        } catch {
            // ignore; caption (if any) remains
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
    let nonWorkingExample =
        "Can someone help me understand why Pauldies profiled the case of [Richard Hess](https://www.youtube.com/watch?v=uphicFoTBFM) beginning at 6:57? "
    ScrollView {
        SnudownView(text: exampleMarkdown)
    }
    .padding(.horizontal, 8)
    .background { Color(uiColor: .tertiarySystemBackground).ignoresSafeArea() }
}

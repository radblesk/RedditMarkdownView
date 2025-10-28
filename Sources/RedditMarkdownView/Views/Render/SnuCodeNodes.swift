import Foundation

class SnuCodeBlock: SnuNode {
    var insideText: String

    init(children: [SnuNode], insideText: String) {
        self.insideText = insideText
        super.init(children: children)
        // Explicitly mark as view so it is rendered by a dedicated view
        self.type = .view
    }
}

class SnuInlineCode: SnuTextNode {
    init(insideText: String) {
        super.init(insideText: insideText, children: [])
        // Mark as view so it doesn't get merged into sibling text groups
        self.type = .view
    }
}

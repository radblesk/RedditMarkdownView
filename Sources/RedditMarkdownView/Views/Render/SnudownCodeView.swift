//
//  SnudownCodeView.swift
//
//
//  Created by Tom Knighton on 10/09/2023.
//

import Highlightr
import SwiftUI
import snudown

struct SnudownCodeView: View {

    @Environment(\.colorScheme) private var scheme

    let code: SnuCodeBlock
    private let highlightr = Highlightr()

    @State private var attributedCode: NSAttributedString? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Group {
//                if let attributedCode {
//                    Text(AttributedString(attributedCode))
//                } else {
                    Text(code.insideText.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.subheadline.monospaced())
//                }
            }
            .lineSpacing(5)
            .padding(4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGray6), in: .rect(cornerRadius: 8))
        .padding(.vertical)
//        .task(priority: .background) {
//            var text = self.code.insideText.trimmingCharacters(in: .whitespacesAndNewlines)
//            var language: String? = nil
//
//            // Only try to detect language for code blocks, not inline code
//            let lines = self.code.insideText.split(separator: "\n", omittingEmptySubsequences: false)
//
//            // Check if first non-empty line is a language identifier
//            if let firstNonEmptyLine = lines.first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) {
//                let potentialLanguage = firstNonEmptyLine.trimmingCharacters(in: .whitespaces).lowercased()
//
//                if let supportedLanguage = highlightr?.supportedLanguages().first(where: { $0 == potentialLanguage }
//                ) {
//                    language = supportedLanguage
//
//                    // Find the index of the language line and drop everything up to and including it
//                    if let langIndex = lines.firstIndex(where: {
//                        $0.trimmingCharacters(in: .whitespaces).lowercased() == potentialLanguage
//                    }) {
//                        text = lines.dropFirst(langIndex + 1).joined(separator: "\n")
//                    }
//                }
//            }
//
//            highlightr?.setTheme(to: self.scheme == .dark ? "xcode-dark" : "xcode")
//            attributedCode = highlightr?.highlight(text, as: language)
//        }
//        .onChange(of: self.scheme) { newValue in
//            self.highlightr?.setTheme(to: newValue == .dark ? "xcode-dark" : "xcode")
//        }
    }
}

#Preview {
    ScrollView {
        VStack {
            SnudownView(
                text: """
                    This is a

                    ```
                    import inlineCode

                    struct Snu: View {
                        var body: some View {
                            /// code here
                            }
                    }
                    ```

                    And this is `inline code`
                    """
            )
        }
        .padding()
    }
}

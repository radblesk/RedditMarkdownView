//
//  SnudownCodeView.swift
//  
//
//  Created by Tom Knighton on 10/09/2023.
//

import SwiftUI
import Highlightr

struct SnudownCodeView: View {
    
    @Environment(\.colorScheme) private var scheme
    
    let code: SnuCodeBlock
    private let highlightr = Highlightr()
    
    @State private var attributedCode: NSAttributedString? = nil
    @State private var copied: Bool = false
        
    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if let attributedCode {
                    Text(AttributedString(attributedCode))
                } else {
                    Text(code.insideText)
                }
            }
            .lineSpacing(5)
            .padding(4)
        }
        .background(Color(.systemGray6), in: .rect(cornerRadius: 8))
        .task(priority: .background) {
            let lines = self.code.insideText.split(separator: "\n").prefix(2)
            var languageToCheck = ""
            if self.code.insideText.hasPrefix("\n") {
                languageToCheck = lines[1].lowercased()
            } else {
                languageToCheck = lines[0].lowercased()
            }
            
            let language = highlightr?.supportedLanguages().first(where: { $0 == languageToCheck })
            var text = self.code.insideText
            if language != nil {
                text = self.code.insideText.split(separator: "\n").dropFirst().joined(separator: "\n")
            }
            
            highlightr?.setTheme(to: self.scheme == .dark ? "xcode-dark" : "xcode")
            attributedCode = highlightr?.highlight(text, as: language)
        }
        .onChange(of: self.scheme) { newValue in
            self.highlightr?.setTheme(to: newValue == .dark ? "xcode-dark" : "xcode")
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            SnudownView(text: "This is a ```import inlineCode```")
        }
        .padding()
    }
}

//
//  MarkdownView.swift
//
//
//  Created by Tom Knighton on 08/09/2023.
//

import Foundation
import SwiftUI

public struct SnudownView: View {
    @Environment(\.snuMaxCharacters) private var maxCharacters
    
    private var components: [SnuParagprah] = []
    
    public init(text: String) {
        self.components = SnudownParser.parseText(text)
    }
    
    public var body: some View {
        SnudownRenderer(paragraphs: (maxCharacters ?? 0) > 0 ? SnudownTruncator.truncateToMaxCharacters(paragraphs: components, maxCharacters: (maxCharacters ?? 0)) : components)
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

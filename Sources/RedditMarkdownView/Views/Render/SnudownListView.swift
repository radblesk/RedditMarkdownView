//
//  File.swift
//  
//
//  Created by Tom Knighton on 10/09/2023.
//

import SwiftUI

struct SnudownListView: View {
    
    @Environment(\.snuTextAlignment) private var align
    
    let list: SnuListNode
    var headingNode: SnuNode? = nil
    
    var body: some View {
        VStack {
            if let headingNode = headingNode as? SnuTextNode {
                SnudownTextView(node: headingNode)
                    .frame(maxWidth: .infinity, alignment: align)
            }
            VStack {
                ForEach(Array(list.children.enumerated()), id: \.element.id) { i, listItem in
                    SnudownRenderSwitch(node: getItem(listItem, index: i))
                        .frame(maxWidth: .infinity, alignment: align)
                }
            }
            .padding(.leading, headingNode == nil ? 0 : 16)
        }
    }
    
    private func getItem(_ originalNode: SnuNode, index: Int) -> SnuNode {
        let indicator = list.isOrdered ? "\(index + 1). " : "• "
        if let listText = originalNode as? SnuTextNode {
            var additionalChildren: [SnuNode] = []
            if listText.insideText.isEmpty {
                if listText.children.contains(where: { $0 is SnuListNode }) {
                    let sublist = listText.children.first(where: { $0 is SnuListNode}) as? SnuListNode
                    let heading = listText.children.first(where: { $0 is SnuTextNode}) as? SnuTextNode
                    var headingText = "\(indicator)\(heading?.insideText ?? "")"
                    if headingText.hasSuffix("\n") {
                        headingText = String(headingText.dropLast())
                    }
                    return SnuListNode(isOrdered: sublist?.isOrdered ?? false, children: sublist?.children ?? [], headerNode: SnuTextNode(insideText: headingText, decoration: heading?.decoration, children: []))
                }
                let listIndicator = SnuTextNode(insideText: indicator, children: [])
                additionalChildren.append(listIndicator)
                additionalChildren.append(contentsOf: listText.children)
                return SnuTextNode(insideText: "", decoration: listText.decoration, children: additionalChildren)
            } else {
                return SnuTextNode(insideText: "\(indicator)\(listText.insideText)", children: listText.children)
            }
        }
        return originalNode
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
        
        ```
        This is a Code Block
        
        Containing multiple lines of code
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
        VStack {
            SnudownView(text: exampleMarkdown)
        }
        .padding()
    }
}

//
//  File.swift
//  
//
//  Created by Tom Knighton on 09/09/2023.
//

import Foundation

enum SnuNodeType {
    case text
    case view
}

class SnuNode: Identifiable {
    var children: [SnuNode]
    let id: UUID = UUID()
    
    var type: SnuNodeType = .view
    
    init(children: [SnuNode]) {
        self.children = children
    }
}

extension SnuNode {
    var isEmpty: Bool {
        if let textNode = self as? SnuTextNode {
            return textNode.insideText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (textNode.children.isEmpty)
        }
        return false
    }
}

//
//  Environment+SnudownConfig.swift
//
//
//  Created by Tom Knighton on 11/09/2023.
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var snuTableColumnAvgWidth: CGFloat = 250
    
    @Entry var snuTextAlignment: Alignment = .leading
    @Entry var snuMultilineTextAlignment: TextAlignment = .leading
    
    @Entry var snuDefaultFont: Font = .callout
    @Entry var snuH1Font: Font = .title.bold()
    @Entry var snuH2Font: Font = .title2.bold()
    @Entry var snuH3Font: Font = .title3.bold()
    @Entry var snuH4Font: Font = .headline.bold()
    @Entry var snuH5Font: Font = .body.bold()
    @Entry var snuH6Font: Font = .subheadline.bold()
    
    @Entry var snuTextColour: Color = .primary
    @Entry var snuLinkColour: Color = .accentColor
    
    @Entry var snuDisplayInlineImages: Bool = true
    @Entry var snuInlineImageWidth: CGFloat = 50
    @Entry var snuInlineImageShowLink: Bool = true
    @Entry var snuMaxCharacters: Int? = nil
    @Entry var snuHideTables: Bool = false
}

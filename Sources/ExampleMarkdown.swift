//
//  ExampleMarkdown.swift
//  RedditMarkdownView
//
//  Created by Radoslav Bley on 28/10/2025.
//

public struct ExampleMarkdown {
    public let defaultMarkdown =
        "#Heading 1\nRedditMarkdownView is a library to automatically handle Reddit's flavour of Markdown (Snudown) and present it in SwiftUI.\nIt can handle:\n\n- lists\n  - layered lists\n\n1. numbered lists\n\nautomatic u/Usernamelinks and /R/subredditlinks\n\nAnd even >!spoilers!< (spoilers)\n\nIt also picks up on links automatically like https://reddit.com\n\n|Column 1|Column 2|\n|-|-:|\n|It even handles tables|with alignment support|\n\nAs well as normal markdown features like **bold** text, *italic*, ~~Strikethrough~~ and all ***~~three combined~~*** :)\n\nAnd just for fun it can handle code blocks too:\n```swift\nlet x = 1\nprint(x)```\n\n"

    public let exampleMarkdown = """
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
        This is a Code Block
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
}

import SwiftUI

struct SnudownInlineCodeView: View {
    let code: SnuInlineCode

    var body: some View {
        Text(code.insideText)
            .font(.system(.subheadline, design: .monospaced))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
            )
    }
}

#Preview {
    SnudownView(text: "This is some `inline code`")
}

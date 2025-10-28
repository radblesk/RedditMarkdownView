import SwiftUI

struct SnudownInlineCodeView: View {
    let code: SnuInlineCode

    var body: some View {
        Text(code.insideText)
            .font(.system(.body, design: .monospaced))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule(style: .continuous)
                    .fill(Color(.systemGray6))
            )
    }
}

#Preview {
    SnudownView(text: "This is some `inline code`")
}

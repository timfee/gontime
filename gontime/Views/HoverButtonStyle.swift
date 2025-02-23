import SwiftUI


struct HoverButtonStyle: ButtonStyle {
    
    static let defaultHeight: CGFloat = 32
    static let defaultCornerRadius: CGFloat = 8
    static let horizontalPadding: CGFloat = 8
    
    @Environment(\.isFocused) private var isFocused
    @State private var isHovered: Bool = false
    
    private let height: CGFloat
    private let cornerRadius: CGFloat
    
    init(height: CGFloat = HoverButtonStyle.defaultHeight, cornerRadius: CGFloat = HoverButtonStyle.defaultCornerRadius) {
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: height)
            .padding(.horizontal, HoverButtonStyle.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isFocused || isHovered ? .primary.opacity(0.1) : Color.clear)
            )
            .contentShape(.rect(cornerRadius: 12.0))
            .onHover { hover in isHovered = hover }
            .focusable()
            .focusEffectDisabled(true)
    }
}

extension ButtonStyle where Self == HoverButtonStyle {
    static var hover: HoverButtonStyle { HoverButtonStyle() }
    
    static func hover(height: CGFloat = HoverButtonStyle.defaultHeight, cornerRadius: CGFloat = HoverButtonStyle.defaultCornerRadius) -> HoverButtonStyle {
        HoverButtonStyle(height: height, cornerRadius: cornerRadius)
    }
}

import SwiftUI

struct HoverButtonStyle: ButtonStyle {
    @Environment(\.isFocused) private var isFocused
    @State private var isHovered: Bool = false
    
    private let height: CGFloat
    private let cornerRadius: CGFloat
    
    init(height: CGFloat = 32, cornerRadius: CGFloat = 8) {
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: height, alignment: .center)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isFocused || isHovered ? .primary.opacity(0.1) : Color.clear)
            )
            .contentShape(.rect(cornerRadius: 3.0))
            .onHover { hover in isHovered = hover }
    }
}

extension ButtonStyle where Self == HoverButtonStyle {
    static var hover: HoverButtonStyle { HoverButtonStyle() }
    
    static func hover(height: CGFloat = 32, cornerRadius: CGFloat = 8) -> HoverButtonStyle {
        HoverButtonStyle(height: height, cornerRadius: cornerRadius)
    }
}


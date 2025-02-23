struct EventRow: View {
    let event: GoogleEvent
    @State var isHovered: Bool = false
    @Environment(\.isFocused) var isFocused
    var body: some View {
        // Define the row content
        Button(action: {
            // Open htmlLink
            NSWorkspace.shared.open(event.htmlLink)
        }) {
            HStack(alignment: .center, spacing: 6) {
                if let startTime = event.formattedStartTime { Text(startTime).font(.subheadline).bold() }
                Text(event.summary ?? "Unnamed event").font(.subheadline).lineLimit(1).truncationMode(.tail)
                Spacer()  // Ensures the Join button is at the trailing edge
                if let url = event.hangoutLink {
                    Link("Join Meeting", destination: url).font(.footnote).foregroundColor(.blue)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isFocused || isHovered ? Color.blue.opacity(0.1) : Color.clear)
        )
        .contentShape(.rect(cornerRadius: 3.0)).frame(height: 44.0).buttonStyle(.plain).focusable()
        .onHover { hover in isHovered = hover }
    }
}
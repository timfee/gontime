import SwiftUI

struct UpdateView: View {
    let updateInfo: UpdateInfo
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Update Available")
                .font(.title2)
                .bold()
            
            // Using AttributedString for HTML rendering
            if let data = updateInfo.message.data(using: .utf8),
               let attributedString = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
               ) {
                Text(AttributedString(attributedString))
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(updateInfo.message)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                if !updateInfo.force {
                    Button("Later") {
                        dismiss()
                    }
                }
                
                Button("Update Now") {
                    if let url = URL(string: updateInfo.url) {
                        openURL(url)
                        if updateInfo.force {
                            // Still need AppKit for app termination
                            NSApplication.shared.terminate(nil)
                        }
                    }
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

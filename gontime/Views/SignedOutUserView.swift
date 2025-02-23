// Rename file to SignedOutUserView.swift
import SwiftUI

struct SignedOutUserView: View {
    let handleSignIn: () -> Void
    
    var body: some View {
        HStack {
            Text("Not signed in")
                .foregroundStyle(.secondary)
            Spacer()
            Button("Sign in", action: handleSignIn)
        }
    }
}

#Preview {
    SignedOutUserView {
        print("Sign in tapped")
    }
    .padding()
    .frame(width: 400)
}

// End of file. No additional code.
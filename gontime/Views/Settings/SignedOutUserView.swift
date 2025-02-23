//
//  SignedOutUserView.swift
//  gontime
//
//  Created by Tim Feeley on 2/21/25.
//

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

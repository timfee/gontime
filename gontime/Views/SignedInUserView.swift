import SwiftUI
import GoogleSignIn

struct UserProfileView: View {
    let user: GIDGoogleUser
    let handleSignOut: () -> Void
    
    var body: some View {
        HStack {
            if let imageURL = user.profile?.imageURL(withDimension: 64) {
                AsyncImage(url: imageURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                }
                .frame(width: 40, height: 40)
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading) {
                Text(user.profile?.name ?? "Unknown")
                    .font(.headline)
                Text(user.profile?.email ?? "Unknown")
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button("Sign out", action: handleSignOut)
        }
    }
}

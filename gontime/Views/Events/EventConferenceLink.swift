//
//  ConferenceLink.swift
//  gontime
//
//  Created by Tim Feeley on 2/22/25.
//

import SwiftUI

struct EventConferenceLink: View {
    
    private enum Constants {
        static let iconSize: CGFloat = 16
        static let trailingPadding: CGFloat = 4
    }
    
    let uri: String
    let solution: ConferenceSolution
    let isInProgress: Bool
    
    var body: some View {
        Link(destination: URL(string: uri)!) {
            conferenceIcon
        }
        .help("Join \(solution.name)")
        .focusable()
        .buttonBorderShape(.roundedRectangle)
        .buttonStyle(.accessoryBar)
        .opacity(isInProgress ? 1.0 : 0.6)
        .padding(.trailing, Constants.trailingPadding)
    }
    
    @ViewBuilder
    private var conferenceIcon: some View {
        if let iconUrl = solution.iconUri,
           let url = URL(string: iconUrl)
        {
            AsyncImage(url: url) { image in
                image.resizable()
                    .frame(
                        width: Constants.iconSize,
                        height: Constants.iconSize
                    )
            } placeholder: {
                Image(systemName: "video.fill")
                    .frame(
                        width: Constants.iconSize,
                        height: Constants.iconSize
                    )
            }
        } else {
            Text(solution.name)
                .font(.footnote)
                .foregroundColor(.blue)
        }
    }
}

//
//  ConferenceButtonStyle.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import SwiftUI

extension View {
  @ViewBuilder
  func buttonStyle(for isInProgress: Bool) -> some View {
    switch isInProgress {
    case true:
      self.buttonStyle(BorderedButtonStyle())
    case false:
      self.buttonStyle(PlainButtonStyle())
    }

  }
}

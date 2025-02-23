//
//  CalendarServiceError.swift
//  gontime
//
//  Created by Tim Feeley on 2/23/25.
//

import Foundation

enum AppError: LocalizedError {
    case auth(Error)
    case calendar(Error)
    case network(Error)
    case decode(Error)
    case request
    case general(String)
    
    var errorDescription: String? {
        switch self {
            case .auth(let error):
                return "Authentication error: \(error.localizedDescription)"
            case .calendar(let error):
                return "Calendar error: \(error.localizedDescription)"
            case .network(let error):
                return "Network error: \(error.localizedDescription)"
            case .decode(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .request:
                return "Invalid request"
            case .general(let message):
                return message
        }
    }
}

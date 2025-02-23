//
//  EventFilter.swift
//  gontime
//

import Foundation
import Defaults

protocol EventFilterProtocol {
    func filter(_ events: [GoogleEvent]) -> [GoogleEvent]
}

struct DefaultEventFilter: EventFilterProtocol {
    func filter(_ events: [GoogleEvent]) -> [GoogleEvent] {
        events.filter { event in
            if Defaults[.ignoreFullDayEvents], event.start?.dateTime == nil {
                return false
            }
            
            if Defaults[.ignoreEventsWithoutAttendees],
               event.attendees?.isEmpty ?? true {
                return false
            }
            
            return true
        }
    }
}

// End of file

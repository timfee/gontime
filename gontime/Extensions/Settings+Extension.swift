//
//  Settings+Extension.swift
//  gontime
//
//  Created by Tim Feeley on 2/21/25.
//

import Defaults


extension Defaults.Keys {
    static let showEventTitleInMenuBar = Key<Bool>("showEventTitleInMenuBar", default: true)
    static let truncatedEventTitleLength = Key<Int>("truncatedEventTitleLength", default: 30)
    static let simplifyEventTitles = Key<Bool>("simplifyEventTitles", default: true)
    static let ignoreFullDayEvents = Key<Bool>("ignoreFullDayEvents", default: true)
    static let ignoreEventsWithoutAttendees = Key<Bool>("ignoreEventsWithoutAttendees", default: true)
}


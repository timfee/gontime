struct GoogleEvent: Codable, Identifiable {
    let id: String
    let summary: String
    let startTime: String?
    let endTime: String?
    let attendees: [String]?
    let htmlLink: String?
}

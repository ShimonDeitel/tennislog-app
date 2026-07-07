import Foundation

struct SessionEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var drillmatch: String   // Drill/Match
    var value1: Int   // Sets Won
    var value2: Int   // Sets Lost
    var note: String = ""
}

enum TennislogOptions {
    static let all: [String] = ["Serve Practice", "Forehand Drill", "Backhand Drill", "Match Play", "Volley Drill"]
}

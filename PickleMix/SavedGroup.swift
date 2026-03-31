import Foundation

struct SavedGroup: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var format: TournamentFormat
    var names: [String]?          // .individuals
    var maleNames: [String]?      // .mixedDoubles
    var femaleNames: [String]?    // .mixedDoubles
    var teamNames: [SavedTeam]?   // .fixedTeams
    var createdAt: Date = Date()
}

struct SavedTeam: Codable {
    var player1: String
    var player2: String
}

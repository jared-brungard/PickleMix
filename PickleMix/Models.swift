import Foundation


// Types of Round Robbins
enum TournamentFormat: String, CaseIterable, Codable {
    case individuals = "Individuals"
    case fixedTeams = "Fixed Teams"
    case mixedDoubles = "Mixed Doubles"
}
// Using UUID() allows for a uniquie ID that helps keep ud sperate if they have the same name for the system
// This could run into a rare error of having a hard time in individul or mixed doubles being able to tell which of the matching names are which,could look into string checks to disallow or make them have different colors, or make one bold. italic or something to that effect.
//Player data, isMale needed for mixed doubles
struct Player: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var isMale: Bool = true
}
//data for teams
struct Team: Identifiable {
    let id = UUID()
    var player1: String
    var player2: String
    var displayName: String { "\(player1) & \(player2)" }
}

//shows match data structure. Have scores for possibilty of score reporting in future.
struct Match: Identifiable {
    let id = UUID()
    var team1: [String]
    var team2: [String]
    var score1: Int = 0
    var score2: Int = 0
    var isCompleted: Bool = false
}

struct PlayerResult: Identifiable {
    let id = UUID()
    var name: String
    var wins: Int = 0
    var losses: Int = 0
    var pointDiff: Int = 0
}

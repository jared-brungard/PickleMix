import Foundation
import Observation

@Observable
class TournamentManager {
    var format: TournamentFormat
    var keepScores: Bool = false
    var rounds: [[Match]] = []
    var completedRounds: Set<Int> = []
    var customRoundCount: Int? = nil
    var byes: [[String]] = []
    var individualPlayers: [String] = []
    var fixedTeams: [Team] = []
    var males: [String] = []
    var females: [String] = []

    var results: [PlayerResult] {
        var stats: [String: PlayerResult] = [:]

        func ensure(_ name: String) {
            if stats[name] == nil { stats[name] = PlayerResult(name: name) }
        }

        for round in rounds {
            for match in round where match.isCompleted {
                let won1 = match.score1 > match.score2
                let diff = match.score1 - match.score2

                if format == .fixedTeams {
                    let key1 = match.team1.joined(separator: " & ")
                    let key2 = match.team2.joined(separator: " & ")
                    ensure(key1); ensure(key2)
                    stats[key1]!.wins    += won1 ? 1 : 0
                    stats[key1]!.losses  += won1 ? 0 : 1
                    stats[key1]!.pointDiff += diff
                    stats[key2]!.wins    += won1 ? 0 : 1
                    stats[key2]!.losses  += won1 ? 1 : 0
                    stats[key2]!.pointDiff -= diff
                } else {
                    for name in match.team1 {
                        ensure(name)
                        stats[name]!.wins    += won1 ? 1 : 0
                        stats[name]!.losses  += won1 ? 0 : 1
                        stats[name]!.pointDiff += diff
                    }
                    for name in match.team2 {
                        ensure(name)
                        stats[name]!.wins    += won1 ? 0 : 1
                        stats[name]!.losses  += won1 ? 1 : 0
                        stats[name]!.pointDiff -= diff
                    }
                }
            }
        }

        return stats.values.sorted {
            if $0.wins != $1.wins { return $0.wins > $1.wins }
            return $0.pointDiff > $1.pointDiff
        }
    }

    init(format: TournamentFormat) {
        self.format = format
    }

    func generateFullTournament() {
        self.rounds = []
        self.completedRounds.removeAll()
        self.byes = []
        switch format {
        case .individuals: generateIndividualMix()
        case .fixedTeams: generateFixedTeamMix()
        case .mixedDoubles: generateMixedDoublesMix()
        }
    }

    private func generateIndividualMix() {
        var allPlayers = individualPlayers
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard Set(allPlayers).count == allPlayers.count else {
            print("ERROR: Duplicate player names found. Names must be unique in Individuals mode.")
            return
        }

        allPlayers.shuffle()
        let totalPlayers = allPlayers.count
        guard totalPlayers >= 4 else { return }   // you need at least 4 to make a match

       
            // If custom isn't set, default to a mathematical standard for round-robin
            let numRounds = customRoundCount ?? (totalPlayers % 2 == 0 ? totalPlayers - 1 : totalPlayers)

            // Tracker for analyzing partner/game history
            var gamesPlayed: [String: Int] = [:]
            var partnerCounts: [String: [String: Int]] = [:]

            // Initialize dictionaries for every player
            for p in allPlayers {
                gamesPlayed[p] = 0
                partnerCounts[p] = [:]
                for other in allPlayers where other != p {
                    partnerCounts[p]![other] = 0
                }
            }

            
            for _ in 0..<numRounds {
                //Ensure nobody has extra byes than what is fair
                allPlayers.shuffle()
                allPlayers.sort { gamesPlayed[$0]! < gamesPlayed[$1]! }

                //Figures out how many courts will be filled
                let maxPlayers = (totalPlayers / 4) * 4
                guard maxPlayers >= 4 else { break }

                // Array of players assigned to matches in the round
                let activePlayers = Array(allPlayers.prefix(maxPlayers))
                
                // Array of players that will sit out and have byes
                let sittingOut = Array(allPlayers.dropFirst(maxPlayers))

                // Everybody that gets into a match adds a game played
                for p in activePlayers {
                    gamesPlayed[p]! += 1
                }

                var roundMatches: [Match] = []
                var unassigned = activePlayers

                // Greedy Algo for assigning partners
                while unassigned.count >= 4 {
    
                    let p1 = unassigned.removeFirst()

                    unassigned.sort { partnerCounts[p1]![$0]! < partnerCounts[p1]![$1]! }
                    let p2 = unassigned.removeFirst()

                    // Update their partnership history after they are matched
                    partnerCounts[p1]![p2]! += 1
                    partnerCounts[p2]![p1]! += 1

                    // Form the opposing team using the same logic
                    let p3 = unassigned.removeFirst()
                    unassigned.sort { partnerCounts[p3]![$0]! < partnerCounts[p3]![$1]! }
                    let p4 = unassigned.removeFirst()

                    partnerCounts[p3]![p4]! += 1
                    partnerCounts[p4]![p3]! += 1

                    // Create the match
                    roundMatches.append(Match(team1: [p1, p2], team2: [p3, p4]))
                }

                rounds.append(roundMatches)
                byes.append(sittingOut)
            }
        }

    private func generateFixedTeamMix() {
        rounds.removeAll()
        byes.removeAll() // A7
        
        
        
        // Shuffled list of teams
        var teams = fixedTeams.shuffled()

        // Makes a place hold team named bye
        if teams.count % 2 != 0 {
            teams.append(Team(player1: "BYE", player2: "BYE"))
        }

        let n = teams.count
        guard n >= 2 else { return }

        var generatedRounds: [[Match]] = []
        generatedRounds.reserveCapacity(n - 1)

        for _ in 0..<(n - 1) {
            var roundMatches: [Match] = []
            roundMatches.reserveCapacity(n / 2)

            for i in 0..<(n / 2) {
                let t1 = teams[i]
                let t2 = teams[n - 1 - i]


                roundMatches.append(
                    Match(
                        team1: [t1.player1, t1.player2],
                        team2: [t2.player1, t2.player2]
                    )
                )
            }

            generatedRounds.append(roundMatches.shuffled())
            
            byes.append([]) //A7

            // rotation: keep index 0 fixed, rotate the rest
            let last = teams.removeLast()
            teams.insert(last, at: 1)
        }

        // Single assignment = single UI update
        rounds = generatedRounds
    }
    private func generateMixedDoublesMix() {
            var allMales = males.shuffled()
            var allFemales = females.shuffled()
            
            let numRounds = customRoundCount ?? 6
            
            // MARK: - Algorithmic Trackers
            var partnerCounts: [String: [String: Int]] = [:]

            // Initialize dictionaries for partner tracking
            for m in allMales {
                partnerCounts[m] = [:]
                for f in allFemales {
                    partnerCounts[m]![f] = 0
                }
            }

            // make sure there are enough men and women to create a match
            guard allMales.count >= 2 && allFemales.count >= 2 else { return }

            // MARK: - Match Generation, forced no byes in this mode
            for _ in 0..<numRounds {
                allMales.shuffle()
                allFemales.shuffle()
                
                var roundMatches: [Match] = []
                var unassignedMales = allMales
                var unassignedFemales = allFemales
                
                // Greedy Algo for creating pairings
                while unassignedMales.count >= 2 && unassignedFemales.count >= 2 {
                    let m1 = unassignedMales.removeFirst()
                    unassignedFemales.sort { partnerCounts[m1]![$0]! < partnerCounts[m1]![$1]! }
                    let f1 = unassignedFemales.removeFirst()
                    partnerCounts[m1]![f1]! += 1
                    
                    let m2 = unassignedMales.removeFirst()
                    unassignedFemales.sort { partnerCounts[m2]![$0]! < partnerCounts[m2]![$1]! }
                    let f2 = unassignedFemales.removeFirst()
                    partnerCounts[m2]![f2]! += 1
                    
                    roundMatches.append(Match(team1: [m1, f1], team2: [m2, f2]))
                }
                
                rounds.append(roundMatches)
                byes.append([])
            }
        }

   
}

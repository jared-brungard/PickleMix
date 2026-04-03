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
        guard totalPlayers >= 4 else { return }

        let numRounds = customRoundCount ?? (totalPlayers % 2 == 0 ? totalPlayers - 1 : totalPlayers)

        if totalPlayers % 4 == 0 || totalPlayers % 4 == 1 {
            // Round-Robin 1-Factorization
            // Guarantees every pair partners exactly once.
            //
            // For n % 4 == 1 (5, 9, 13…): a ghost "__BYE__" player is added to
            // make the count even. Whoever is paired with the ghost sits out that
            // round. The ghost rotates through every position, so byes are
            // distributed one-per-player and every real pair still partners once.

            let ghost = "__BYE__"
            var working = allPlayers
            if totalPlayers % 4 == 1 { working.append(ghost) }

            let m = working.count          // even
            let fixed  = working[m - 1]   // anchor — never moves
            var rotating = Array(working.dropLast())   // m-1 players that rotate

            for _ in 0..<(m - 1) {
                // Build pairs: anchor with rotating[0], then symmetric pairs
                var pairs: [(String, String)] = [(fixed, rotating[0])]
                for i in 1..<(m / 2) {
                    pairs.append((rotating[i], rotating[m - 1 - i]))
                }

                // Separate ghost pairings (byes) from real matchups
                var activePairs: [(String, String)] = []
                var roundByes: [String] = []
                for (a, b) in pairs {
                    if a == ghost { roundByes.append(b) }
                    else if b == ghost { roundByes.append(a) }
                    else { activePairs.append((a, b)) }
                }

                // Shuffle pairs before grouping so opponents vary across rounds
                activePairs.shuffle()

                // Group consecutive pairs into courts: pair[0]+pair[1] → court 1, etc.
                var roundMatches: [Match] = []
                var i = 0
                while i + 1 < activePairs.count {
                    let (p1, p2) = activePairs[i]
                    let (p3, p4) = activePairs[i + 1]
                    roundMatches.append(Match(team1: [p1, p2], team2: [p3, p4]))
                    i += 2
                }

                rounds.append(roundMatches)
                byes.append(roundByes)

                // Rotate: move last element of rotating list to the front
                let last = rotating.removeLast()
                rotating.insert(last, at: 0)
            }

        } else {
            // Greedy algorithm for counts where a perfect schedule is impossible
            // (n % 4 == 2 or n % 4 == 3). Minimises repeat partnerships.

            var gamesPlayed:  [String: Int]          = [:]
            var partnerCounts: [String: [String: Int]] = [:]

            for p in allPlayers {
                gamesPlayed[p] = 0
                partnerCounts[p] = [:]
                for other in allPlayers where other != p {
                    partnerCounts[p]![other] = 0
                }
            }

            for _ in 0..<numRounds {
                // Prioritise players with the fewest games so byes stay fair
                allPlayers.shuffle()
                allPlayers.sort { gamesPlayed[$0]! < gamesPlayed[$1]! }

                let maxPlayers = (totalPlayers / 4) * 4
                guard maxPlayers >= 4 else { break }

                let activePlayers = Array(allPlayers.prefix(maxPlayers))
                let sittingOut    = Array(allPlayers.dropFirst(maxPlayers))

                for p in activePlayers { gamesPlayed[p]! += 1 }

                var roundMatches: [Match] = []
                var unassigned = activePlayers

                while unassigned.count >= 4 {
                    let p1 = unassigned.removeFirst()
                    unassigned.sort { partnerCounts[p1]![$0]! < partnerCounts[p1]![$1]! }
                    let p2 = unassigned.removeFirst()
                    partnerCounts[p1]![p2]! += 1
                    partnerCounts[p2]![p1]! += 1

                    let p3 = unassigned.removeFirst()
                    unassigned.sort { partnerCounts[p3]![$0]! < partnerCounts[p3]![$1]! }
                    let p4 = unassigned.removeFirst()
                    partnerCounts[p3]![p4]! += 1
                    partnerCounts[p4]![p3]! += 1

                    roundMatches.append(Match(team1: [p1, p2], team2: [p3, p4]))
                }

                rounds.append(roundMatches)
                byes.append(sittingOut)
            }
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

import SwiftUI

struct PlayerEntryView: View {
    let format: TournamentFormat
    let count: Int
    let customRounds: Int?
    let keepScores: Bool

    @State private var names: [String]
    @State private var maleNames: [String]
    @State private var femaleNames: [String]
    @State private var teamNames: [Team]
    @State private var activeManager: TournamentManager? = nil
    @State private var showTournament: Bool = false


    init(format: TournamentFormat, count: Int, customRounds: Int? = nil, keepScores: Bool = false) {
        self.format = format
        self.count = count
        self.customRounds = customRounds
        self.keepScores = keepScores
        
        _names = State(initialValue: Array(repeating: "", count: count))
        _maleNames = State(initialValue: Array(repeating: "", count: count / 2))
        _femaleNames = State(initialValue: Array(repeating: "", count: count / 2))
        //_teamNames = State(initialValue: Array(repeating: Team(player1: "", player2: ""), count: count))
        _teamNames = State(initialValue: (0..<count).map { _ in Team(player1: "", player2: "") })
    }

    var body: some View {
        Form {
            switch format {
            case .individuals:
                individualsLayout
            case .mixedDoubles:
                mixedDoublesLayout
            case .fixedTeams:
                fixedTeamsLayout
            }
        }
        .navigationTitle("Entry")
        .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mix") {
                        // 1. Create it
                        let manager = createManager()
                        // 2. Generate the matches
                        manager.generateFullTournament()
                        // 3. Save it to our state so SwiftUI doesn't delete it
                        activeManager = manager
                        // 4. Trigger the navigation
                        showTournament = true
                    }
                     .disabled(isMixDisabled)
                }
            }
        .navigationDestination(isPresented: $showTournament) {
                if let manager = activeManager {
                    TournamentView(manager: manager)
                }
            }
    }

    // MARK: - Individuals Layout
    @ViewBuilder
    private var individualsLayout: some View {
        Section(header: Text("Players")) {
            ForEach(0..<count, id: \.self) { i in
                TextField("Player \(i + 1)", text: $names[i])
            }
        }
    }
    // MARK: - Mixed Doubles Layout
    @ViewBuilder
    var mixedDoublesLayout: some View {
        // First Section just for Men
        Section(header: Text("Men")) {
            ForEach(0..<(count / 2), id: \.self) { i in
                TextField("Male \(i + 1)", text: $maleNames[i])
            }
        }
        
        // Second Section just for Women
        Section(header: Text("Women")) {
            ForEach(0..<(count / 2), id: \.self) { i in
                TextField("Female \(i + 1)", text: $femaleNames[i])
            }
        }
    }
    
    // MARK: - Fixed Teams Layout
    @ViewBuilder
    var fixedTeamsLayout: some View {
        ForEach(0..<count, id: \.self) { i in
            // Each team gets its own visual block
            Section(header: Text("Team \(i + 1)")) {
                TextField("Player 1", text: $teamNames[i].player1)
                TextField("Player 2", text: $teamNames[i].player2)
            }
        }
    }
    func createManager() -> TournamentManager {
            let manager = TournamentManager(format: format)
            manager.keepScores = self.keepScores
            manager.customRoundCount = self.customRounds
            manager.individualPlayers = self.names
            manager.fixedTeams = self.teamNames
            manager.males = self.maleNames
            manager.females = self.femaleNames
            return manager
        }
    var isMixDisabled: Bool {
            switch format {
            case .individuals:
                // Checks if any individual name field is empty
                return names.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty })
            case .mixedDoubles:
                // Checks if any male or female name field is empty
                return maleNames.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty }) ||
                       femaleNames.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty })
            case .fixedTeams:
                // Checks if either player in any team is empty
                return teamNames.contains(where: { $0.player1.trimmingCharacters(in: .whitespaces).isEmpty ||
                                                   $0.player2.trimmingCharacters(in: .whitespaces).isEmpty })
            }
        }
}


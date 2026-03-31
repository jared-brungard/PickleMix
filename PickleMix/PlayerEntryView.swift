import SwiftUI

struct PlayerEntryView: View {
    let format: TournamentFormat
    let count: Int
    let customRounds: Int?
    let keepScores: Bool

    @Environment(GroupsStore.self) private var store
    @State private var names: [String]
    @State private var maleNames: [String]
    @State private var femaleNames: [String]
    @State private var teamNames: [Team]
    @State private var activeManager: TournamentManager? = nil
    @State private var showTournament: Bool = false
    @State private var showLoadSheet: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var newGroupName: String = ""


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
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Load") { showLoadSheet = true }
                    .disabled(store.groups.isEmpty)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Save") {
                    newGroupName = ""
                    showSaveAlert = true
                }
            }
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
        .alert("Save to My Groups", isPresented: $showSaveAlert) {
            TextField("Group name", text: $newGroupName)
            Button("Save") {
                let trimmed = newGroupName.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                store.save(group: buildSavedGroup(named: trimmed))
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a name for this group.")
        }
        .sheet(isPresented: $showLoadSheet) {
            LoadGroupView(store: store) { selectedNames in
                applySelectedNames(selectedNames)
                showLoadSheet = false
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
    private func buildSavedGroup(named name: String) -> SavedGroup {
        var allNames: [String]
        switch format {
        case .individuals:
            allNames = names
        case .mixedDoubles:
            allNames = maleNames + femaleNames
        case .fixedTeams:
            allNames = teamNames.flatMap { [$0.player1, $0.player2] }
        }
        return SavedGroup(name: name, players: allNames.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty })
    }

    private func applySelectedNames(_ selected: [String]) {
        switch format {
        case .individuals:
            for i in names.indices {
                names[i] = i < selected.count ? selected[i] : ""
            }
        case .mixedDoubles:
            // Fill males first, then females
            for i in maleNames.indices {
                maleNames[i] = i < selected.count ? selected[i] : ""
            }
            let offset = maleNames.count
            for i in femaleNames.indices {
                femaleNames[i] = (offset + i) < selected.count ? selected[offset + i] : ""
            }
        case .fixedTeams:
            // Pair names consecutively into teams
            for i in teamNames.indices {
                teamNames[i].player1 = (i * 2) < selected.count ? selected[i * 2] : ""
                teamNames[i].player2 = (i * 2 + 1) < selected.count ? selected[i * 2 + 1] : ""
            }
        }
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


import SwiftUI

struct TournamentView: View {
    // We use @Bindable here so we can modify the manager's completedRounds set
    @Bindable var manager: TournamentManager

    var body: some View {
        VStack {
            if manager.rounds.isEmpty {
                VStack(spacing: 20) {
                    ProgressView()
                    Text("Generating Mix...")
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(0..<manager.rounds.count, id: \.self) { roundIndex in
                        let isCompleted = manager.completedRounds.contains(roundIndex)
                        
                        // Create a section for each round
                        Section(header: roundHeader(for: roundIndex, isCompleted: isCompleted)) {
                            // Only show the matches and byes if the round is NOT completed
                            if !isCompleted {
                                
                                // 1. Show the matches
                                ForEach($manager.rounds[roundIndex]) { $match in
                                    MatchRow(match: $match, keepScores: manager.keepScores)
                                }
                                
                                // 2. Show the Byes (Safely checking bounds to prevent crashes)
                                if roundIndex < manager.byes.count && !manager.byes[roundIndex].isEmpty {
                                    HStack {
                                        Text("Byes:")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.secondary)
                                        Text(manager.byes[roundIndex].joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                    // Gives the bye row a subtle gray background
                                    .listRowBackground(Color.gray.opacity(0.15))
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if manager.keepScores {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Results") {
                        ResultsView(manager: manager)
                    }
                }
            }
        }
        .onAppear {
            if manager.rounds.isEmpty {
                manager.generateFullTournament()
            }
        }
    }
    
    // MARK: - Custom Round Header
    @ViewBuilder
    func roundHeader(for index: Int, isCompleted: Bool) -> some View {
        HStack {
            Text("Round \(index + 1)")
                .font(.headline)
                .foregroundColor(isCompleted ? .secondary : .primary)
            
            Spacer()
            
            // The Checkmark Button
           Button(action: {
                // withAnimation makes the matches smoothly slide out of view
                withAnimation(.easeInOut) {
                    if isCompleted {
                        manager.completedRounds.remove(index)
                        for i in manager.rounds[index].indices {
                            manager.rounds[index][i].isCompleted = false
                        }
                    } else {
                        manager.completedRounds.insert(index)
                        for i in manager.rounds[index].indices {
                            manager.rounds[index][i].isCompleted = true
                        }
                    }
                }
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .blue)
                    .font(.title2)
            }
            .buttonStyle(.plain) // Prevents the whole section header from acting like a button
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Match Row Subview
struct MatchRow: View {
    @Binding var match: Match
    let keepScores: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if keepScores {
                HStack {
                    Text(match.team1.joined(separator: " & "))
                        .fontWeight(.semibold)
                    Spacer()
                    TextField("0", value: $match.score1, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 44)
                        .textFieldStyle(.roundedBorder)
                }

                Text("VS")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)

                HStack {
                    Text(match.team2.joined(separator: " & "))
                        .fontWeight(.semibold)
                    Spacer()
                    TextField("0", value: $match.score2, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 44)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Spacer()
                    Button(action: { match.isCompleted.toggle() }) {
                        Label(
                            match.isCompleted ? "Completed" : "Mark Complete",
                            systemImage: match.isCompleted ? "checkmark.circle.fill" : "circle"
                        )
                        .font(.caption)
                        .foregroundColor(match.isCompleted ? .green : .blue)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack {
                    Text(match.team1.joined(separator: " & "))
                        .fontWeight(.semibold)
                    Spacer()
                }

                Text("VS")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)

                HStack {
                    Text(match.team2.joined(separator: " & "))
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
    }
}

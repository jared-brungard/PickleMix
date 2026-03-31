import SwiftUI

struct CreateGroupView: View {
    @Environment(GroupsStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var existingGroup: SavedGroup? = nil

    @State private var groupName: String = ""
    @State private var players: [String] = [""]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Group Name")) {
                    TextField("e.g. Thursday Crew", text: $groupName)
                }

                Section(header: Text("Players")) {
                    ForEach(players.indices, id: \.self) { i in
                        HStack {
                            TextField("Player \(i + 1)", text: $players[i])
                            if players.count > 1 {
                                Button(action: { players.remove(at: i) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button(action: { players.append("") }) {
                        Label("Add Player", systemImage: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle(existingGroup == nil ? "Create Group" : "Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let filledPlayers = players.map { $0.trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty }
                        if var existing = existingGroup {
                            existing.name = groupName.trimmingCharacters(in: .whitespaces)
                            existing.players = filledPlayers
                            store.update(group: existing)
                        } else {
                            let group = SavedGroup(
                                name: groupName.trimmingCharacters(in: .whitespaces),
                                players: filledPlayers
                            )
                            store.save(group: group)
                        }
                        dismiss()
                    }
                    .disabled(!isSaveEnabled)
                }
            }
            .onAppear {
                if let existing = existingGroup {
                    groupName = existing.name
                    players = existing.players.isEmpty ? [""] : existing.players
                }
            }
        }
    }

    private var isSaveEnabled: Bool {
        let trimmedName = groupName.trimmingCharacters(in: .whitespaces)
        let filledPlayers = players.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return !trimmedName.isEmpty && !filledPlayers.isEmpty
    }
}

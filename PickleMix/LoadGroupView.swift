import SwiftUI

// MARK: - Group List
struct LoadGroupView: View {
    let store: GroupsStore
    let onSelect: ([String]) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.groups) { group in
                    NavigationLink(destination: PlayerPickerView(group: group, onConfirm: { selected in
                        onSelect(selected)
                        dismiss()
                    })) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(group.name)
                                .font(.headline)
                            Text("\(group.players.count) players")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { store.groups[$0] }.forEach { store.delete(group: $0) }
                }
            }
            .navigationTitle("Load Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}

// MARK: - Player Checklist
struct PlayerPickerView: View {
    let group: SavedGroup
    let onConfirm: ([String]) -> Void

    @State private var selectedIndices: Set<Int> = []

    var body: some View {
        List {
            ForEach(group.players.indices, id: \.self) { i in
                Button(action: {
                    if selectedIndices.contains(i) {
                        selectedIndices.remove(i)
                    } else {
                        selectedIndices.insert(i)
                    }
                }) {
                    HStack {
                        Text(group.players[i])
                            .foregroundStyle(.primary)
                        Spacer()
                        if selectedIndices.contains(i) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Use \(selectedIndices.count)") {
                    let selected = selectedIndices.sorted().map { group.players[$0] }
                    onConfirm(selected)
                }
                .disabled(selectedIndices.isEmpty)
                .fontWeight(.semibold)
            }
        }
    }
}

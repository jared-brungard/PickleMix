import SwiftUI

struct MyGroupsView: View {
    @Environment(GroupsStore.self) private var store
    @State private var showCreateSheet = false
    @State private var groupToEdit: SavedGroup? = nil

    var body: some View {
        Group {
            if store.groups.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.3")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No saved groups yet.")
                        .foregroundColor(.secondary)
                    Button("Create a Group") { showCreateSheet = true }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                }
            } else {
                List {
                    ForEach(store.groups) { group in
                        Button(action: { groupToEdit = group }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(group.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(group.players.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.map { store.groups[$0] }.forEach { store.delete(group: $0) }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("My Groups")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showCreateSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateGroupView()
        }
        .sheet(item: $groupToEdit) { group in
            CreateGroupView(existingGroup: group)
        }
    }
}

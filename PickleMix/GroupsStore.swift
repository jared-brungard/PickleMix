import Foundation
import Observation

@Observable
class GroupsStore {
    var groups: [SavedGroup] = []

    private let defaultsKey = "com.picklemix.savedGroups"

    init() {
        load()
    }

    func save(group: SavedGroup) {
        groups.append(group)
        persist()
    }

    func delete(group: SavedGroup) {
        groups.removeAll { $0.id == group.id }
        persist()
    }

    func update(group: SavedGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
            persist()
        }
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([SavedGroup].self, from: data)
        else { return }
        groups = decoded
    }
}

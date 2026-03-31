import Foundation

struct SavedGroup: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var players: [String] = []
    var createdAt: Date = Date()
}

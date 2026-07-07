import Foundation

struct SightingEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var species: String
    var location: String
    var habitat: String
    var notes: String
    var dateCreated: Date = Date()
}

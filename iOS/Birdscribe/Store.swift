import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [SightingEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 23

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("birdscribe_entries.json")
    }()

    init() {
        load()
        if entries.isEmpty {
            seed()
        }
    }

    func seed() {
        entries = [
        SightingEntry(name: "Northern Cardinal", species: "Cardinalis cardinalis", location: "Backyard feeder", habitat: "Suburban", notes: "Male, bright red"),
        SightingEntry(name: "Great Blue Heron", species: "Ardea herodias", location: "Riverside wetland", habitat: "Wetland", notes: "Fishing at dawn"),
        SightingEntry(name: "Black-capped Chickadee", species: "Poecile atricapillus", location: "Trail head", habitat: "Woodland", notes: "Flock of five")
        ]
        save()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(species: String, location: String, habitat: String, notes: String) {
        guard canAddMore else { return }
        let entry = SightingEntry(name: name, species: species, location: location, habitat: habitat, notes: notes)
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: SightingEntry) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: SightingEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([SightingEntry].self, from: data) {
            entries = decoded
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

import Foundation

class DataStore {
    static let shared = DataStore()
    private let fileManager = FileManager.default

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func save<T: Codable>(_ data: T, to filename: String) {
        let url = documentsURL.appendingPathComponent(filename)
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url)
        } catch {
            print("Failed to save \(filename): \(error)")
        }
    }

    func load<T: Codable>(_ type: T.Type, from filename: String) -> T? {
        let url = documentsURL.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Failed to load \(filename): \(error)")
            return nil
        }
    }

    func delete(_ filename: String) {
        let url = documentsURL.appendingPathComponent(filename)
        try? fileManager.removeItem(at: url)
    }
}

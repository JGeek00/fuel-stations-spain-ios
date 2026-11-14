import Foundation

/// Carga fixtures JSON empaquetados como recursos del bundle de tests.
enum FixtureLoader {
    static func data(_ name: String, bundle: Bundle = Bundle(for: BundleToken.self)) throws -> Data {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            struct Missing: Error {}
            throw Missing()
        }
        return try Data(contentsOf: url)
    }

    static func string(_ name: String, bundle: Bundle = Bundle(for: BundleToken.self)) throws -> String {
        String(decoding: try data(name, bundle: bundle), as: UTF8.self)
    }
}

private final class BundleToken {}

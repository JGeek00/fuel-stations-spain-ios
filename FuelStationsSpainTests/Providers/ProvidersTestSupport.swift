import Foundation
@testable import FuelStationsSpain

/// Fábrica de `FuelStation` vía decode de JSON mínimo (los campos obligatorios
/// del modelo; el resto son opcionales o los cubren los valores por defecto).
func makeFuelStation(
    id: String,
    signage: String = "REPSOL",
    address: String = "Calle Falsa 123",
    locality: String = "Madrid"
) -> FuelStation {
    let json = """
    {"id":"\(id)","postalCode":"28001","address":"\(address)","openingHours":"L-D: 24h",\
    "latitude":40.4,"longitude":-3.7,"locality":"\(locality)","signage":"\(signage)",\
    "percBioEthanol":"","percMethylEster":"","municipalityId":1,"provinceId":1,"regionId":1}
    """
    return try! JSONDecoder().decode(FuelStation.self, from: Data(json.utf8))
}

/// Ejecuta el bloque con los defaults "desechables": guarda el valor actual de
/// cada clave, lo borra y lo restaura al terminar (con o sin error). Los
/// migradores y los wrappers leen `UserDefaults.shared` (suite del app group),
/// que no admite sustitución; la limpieza evita ensuciar el entorno del host.
enum DisposableDefaults {
    @MainActor
    static func run(keys: [String], _ body: () throws -> Void) rethrows {
        let defaults = UserDefaults.shared
        let backups = keys.map { ($0, defaults.object(forKey: $0)) }
        defer {
            for (key, value) in backups {
                if let value {
                    defaults.set(value, forKey: key)
                } else {
                    defaults.removeObject(forKey: key)
                }
            }
        }
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        try body()
    }
}

# Tests lógica no-UI — cobertura máxima

Añadir tests a toda la lógica de la app, máxima cobertura en ficheros sin UI.
Alcance: `Models/`, `Utils/`, `Services/`, `Providers/` (lógica), `Constants/`, `Extensions/`.
Fuera: `Views/`, `Components/`, widgets UI, previews.

## Specs

- S1: "vamos a añadir test a toda la lógica de la app"
- S2: "Buscamos la mayor cobertura de código posible en ficheros que no lleven UI"
- S3 (de `architecture-migration.md` S5): "Sin test targets en el proyecto; cada fase que toque lógica debe dejar tests donde hoy no hay ninguno."

## Tasks

- T1 (S1,S2,S3, route: worker, commit: `test(infra): add unit test target + stub harness`): crear test target al app target + `URLProtocol` stub + fixture loader + Core Data en memoria (`PersistenceController.init(inMemory:)` ya existe).
- T2 (S1,S2, route: worker, commit: `test(models): decode + price mapping`): fixtures JSON por modelo (`FuelStationsResult`, `MunicipalitiesResult`, `HistoricPrice`, `AppStoreInfoResult`) + round-trip + errores de decode.
- T3 (S1,S2, route: worker, commit: `test(utils): stations dates formatters`): `Stations.swift` (haversine, distancias, sorts), `Dates.swift`, `NumberFormatter`, `Schedule`, `Maps`, `CustomJSONEncoder`; un test por regla + sus bordes.
- T4 (S1,S2, route: worker, commit: `test(network): ApiClient con sesión stubeada`): `HTTPClient` (200/decode-ok, ≥400 con `rawBody`, timeout, error de red) + los 5 fetches de `ApiClient` con URLs y query items verificados.
- T5 (S1,S2, route: worker, commit: `test(providers): favorites + settings stores`): `FavoritesProvider` CRUD/alias sobre store en memoria, wrappers `SortingValue`/`FavoriteFuelValue` fallback, migraciones (`FavoriteFuelMigrator`, `SortingMigrator`).
- T6 (S1,S2, route: inline, commit: `test(coverage): gate + informe final`): medir cobertura solo-no-UI, listar huecos con motivo (qué no se cubre y por qué), dejar puerta a CI.
- T7 (S1,S2, route: worker, commit: `test(viewmodels): lógica no-UI de ViewModels`): `ServiceStationHistoricViewModel.generateChartData` (rangos, min/max, punto seleccionado, fuel sin precios), `SearchViewModel` (groupBy provincia/inicial, sort/filter, fetch con stub), `FavoritesListViewModel` (fetch con stub + provider en memoria); sin tocar vistas.

## Log

- L1 (verbatim): "Eso es, vamos a añadir test a toda la lógica de la app. Buscamos la mayor cobertura de código posible en ficheros que no lleven UI"
- L4: T6 gate 121/121 en serie + 62,75% no-UI; slice boundary: 7 commits (fix + 5 test + docs) en tests/non-ui-coverage, ~2.389 líneas.
- L5 (verbatim): "Si" — en respuesta a cubrir ViewModels (mayor hueco: ServiceStationHistoricViewModel 270 líneas al 0%).

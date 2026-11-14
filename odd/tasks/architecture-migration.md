# Migración arquitectónica — HispaFuel (FuelStationsSpain)

Plan para salir del modelo actual (singletons globales + ViewModels con dependencias
cruzadas) a features con dependencias inyectadas + `FuelRepository` único.
Stack: iOS 17+ (app Swift 6.0, widgets Swift 5.0), sin test targets hoy, 2 deps SPM solo en app.

## Specs

- S1: "Usa una arquitectura antigua y poco óptima, los viewmodel tienen dependencias cruzadas entre sí."
- S2: "Quiero que analices el código, entiendas lo que hace y las features que tiene la app, y me propongas una nueva arquitectura óptima para esta app."
- S3: "Vale, empieza elaborando el documento de migracion"
- S4: "Solo es el mapa lo que no carga" + "Era la posición inicial" (bugfix previo ya aplicado: fallback a Madrid en `RootView`, timeout 15s + `Accept` en `HTTPClient`; no regressar estos comportamientos).
- S5: Sin test targets en el proyecto; cada fase que toque lógica debe dejar tests donde hoy no hay ninguno.

## Estado actual (resumen verificado)

- Composición en `FuelStationsSpainApp.swift:10-39`: 10 objetos vivos siempre (5 singletons `.shared` + 5 instancias) inyectados como `environmentObject`. `SearchViewModel.init` y `FavoritesListViewModel.init` hacen fetch de red al arrancar.
- Dependencias cruzadas: `FavoritesListViewModel.fetchData` → `FavoritesProvider.shared` (`ViewModels/FavoritesListViewModel.swift:21`); `FavoritesProvider` → `ToastProvider.shared`; re-inyección manual de `.shared` en `MapView.swift:188`, `MapItem.swift:181-182`, `FavoriteButton.swift:93`, `StationListEntry.swift:275`.
- Red: `Utils/HTTPClient.swift` (función global, `StatusResponse` booleano); `Services/ApiClient.swift` (5 endpoints, clase estática). Decodificación de precios vía `Mirror` (`FuelStationsResult.swift:60-70`, `FuelStationsHistoricResult.swift` `price(for:)`).
- Estado disperso: 15 keys en `Constants/StorageKeys.swift:1-18` + `Defaults.swift` + wrappers `SortingValue` (`Providers/SortingValue.swift`) y `FavoriteFuelValue` (`Providers/FavoriteFuel.swift`), ~30 call sites de `UserDefaults.shared` (App Group, acopla app↔widgets).
- Widgets `PriceWidget/` y `PriceHistoryWidget/`: 5 archivos espejo cada uno (`Utils.swift` idénticos) + ~12 shared files por `fileSystemSynchronizedGroups` (`project.pbxproj:75-147`); dependen de singletons globales, nada de ViewModels es reutilizable.
- Lógica pesada en `@MainActor`/vistas: `groupBy` de ~8k municipios en `SearchViewModel.swift:59-124`, sort/filter en `FavoritesView.body`, `DispatchQueue.global/main.async` dentro de ViewModels.

## Arquitectura objetivo

```
App/                  composición root: DIContainer + Router (nada de lógica)
Core/
  Networking/         HTTPClient (errores tipados ApiError, timeout, retry 429) + FuelRepository protocol + Live/Mock
  Persistence/        FavoritesStore protocol (Core Data detrás, en App Group)
  Location/           LocationService protocol (stream AsyncStream, + Mock Madrid)
  Settings/           SettingsStore @Observable (las 15 keys tipadas, 1 migración)
Shared/UI/            Componentes puros (lo actual de Components/, sin singletons)
Features/
  Map/ Search/ Favorites/ Historic/ Settings/ Onboarding/   (Feature @Observable + Views, init(repo:store:…))
WidgetsKit/           target compartido: AppIntent, Utils, MockStation, timeline (saca duplicados)
```

Principios: un Feature = un estado `@Observable` con dependencias por `init` (cero `.shared` en features); todo `await` fuera del `init` (disparo desde `.task`); errores tipados, nunca `successful: Bool`; precios por `KeyPath` de `FuelType`, nunca `Mirror`; `UserDefaults.shared` solo dentro de `SettingsStore`/`FavoritesStore`.

## Tasks

- T1 (S1,S3,S5, route: worker, commit: `refactor(network): tipar HTTPClient y extraer FuelRepository`): crear `Core/Networking` con `ApiError`, `FuelRepository` protocol + `LiveFuelRepository` + `Mock`, `ApiClient` queda como fachada temporal; añadir test target + tests de decode y 429.
- T2 (S1,S3,S5, route: worker, commit: `refactor(settings): SettingsStore tipado único`): `SettingsStore @Observable` con las 15 keys (`StorageKeys`+`Defaults`), migrar `SortingValue`/`FavoriteFuelValue` y call sites, 1 sola migración al arrancar; tests del fallback.
- T3 (S1,S3,S5, route: worker, commit: `refactor(favorites): FavoritesStore desacoplado de Toast`): `FavoritesStore` protocol sobre Core Data, `FavoritesListViewModel` con `init(store:repo:)` sin `FavoritesProvider.shared`, toasts como efecto de UI; tests con store en memoria.
- T4 (S1,S3,S4,S5, route: worker, commit: `refactor(map): MapFeature con ubicación inyectada`): `LocationService` + `MapFeature @Observable`, eliminar `MapManager.shared` y re-inyecciones (`MapView:188`, `MapItem:181`), conservar fallback a Madrid/8s y gate por permiso; tests del fallback sin GPS.
- T5 (S1,S3,S5, route: worker, commit: `refactor(search): SearchFeature sin fetch en init`): `SearchViewModel` → `SearchFeature(init(repo:))`, fetch desde `.task`, `groupBy`/sort/filter fuera del MainActor; tests de agrupado con fixture de municipios.
- T6 (S1,S3, route: inline, commit: `refactor(navigation): Router explícito`): `Router` por `NavigationStack(path:)` en Search/Favorites, sacar `navigationPath` del ViewModel; cambio mecánico, verificar navegación iPhone + Split iPad.
- T7 (S1,S3,S5, route: inline, commit: `refactor(models): precios por KeyPath, sin Mirror`): `FuelType.price(of:)` por `KeyPath`, eliminar `getObjectProperty` y `price(for:)` con `Mirror`; tests que cada fuel mapea su campo.
- T8 (S1,S3, route: worker, commit: `refactor(widgets): WidgetsKit compartido`): nuevo target `WidgetsKit` con AppIntent/Utils/Mock/timeline únicos, los 2 widgets lo importan; ojo Swift 5 (widgets) vs 6 (app): el shared debe compilar en ambos; verificar timelines 30min y alias de Core Data.

## Orden y dependencias

T1 primero (base de todo) → T2 y T3 en paralelo (disjuntos) → T4 (usa LocationService nuevo; conserva S4) → T5 → T6 → T7 (toca modelos usados por T3-T5, por eso va después) → T8 último (consume stores/models finales). No empezar T4/T5 sin T1. `TabViewManager` (un valor) colapsa a `@State` en `App` cuando T4-T6 liberen el entorno; `IAPManager` (StoreKit 1) se moderniza fuera de este plan.

## Riesgos

- Shared files compilan en Swift 5 y 6 a la vez: prohibido sintaxis solo-6 en `Core` hasta unificar a 6.0.
- `UserDefaults.shared` (App Group) lo leen app y widgets: `SettingsStore` debe mantener keys y formatos actuales o rompe widgets y migraciones (`FavoriteFuelMigrator`, `SortingMigrator` en `App.init` + `AppDelegate`).
- Sin tests hoy: cada T crea su fixture (nunca leer git/history en tests); no bajar el listón si un runner no está disponible.

## Log

- L1 (verbatim): "Este proyecto es una app iOS hecha con SwiftUI para ver el precio del combustible en España. Usa una arquitectura antigua y poco óptima, los viewmodel tienen dependencias cruzadas entre sí. Quiero que analices el código, entiendas lo que hace y las features que tiene la app, y me propongas una nueva arquitectura óptima para esta app."
- L2: bugfix mapa sin ubicación aplicado y verificado por usuario ("Era la posición inicial"): fallback Madrid + timeout 15s + `Accept`; S4 lo protege como no-regresión.
- L3 (verbatim): "Vale, empieza elaborando el documento de migracion"

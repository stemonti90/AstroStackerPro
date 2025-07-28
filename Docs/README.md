# AstroStackerPro

Questo progetto raccoglie il codice sorgente e la documentazione dell'app.

## Cartelle
- `AstroStackerPro/Sources/` – codice Swift dell'app
- `AstroStackerPro/Assets/` – asset grafici di esempio
- `AstroStackerPro/Models/` – eventuali modelli CoreML
- `Docs/` – documentazione e changelog
- `Docs/LightPollution.geojson` – dati di esempio sull'inquinamento luminoso

## Build
L'app richiede Xcode 15 e iOS 17. Genera il progetto con **XcodeGen** tramite:

```bash
xcodegen generate
```

Successivamente apri `AstroStackerPro.xcodeproj`, imposta il Bundle ID e compila su dispositivo.

Per le API meteo di OpenWeather è necessario inserire la chiave nel file `Config.plist` (esempio in `Config.plist.example`).


- Workflow CI su GitHub Actions per build automatica

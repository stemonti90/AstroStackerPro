# AstroStackerPro

Questo progetto raccoglie il codice sorgente e la documentazione dell'app.

## Cartelle
- `Sources/` – codice Swift dell'app
- `Assets/` – asset grafici di esempio
- `Models/` – eventuali modelli CoreML
- `Docs/` – documentazione e changelog

## Build
L'app richiede Xcode 15 e iOS 17. Genera il progetto con **XcodeGen** tramite:

```bash
xcodegen generate
```

Successivamente apri `AstroStackerPro.xcodeproj`, imposta il Bundle ID e compila su dispositivo.

Per le API meteo di OpenWeather è necessario inserire la chiave nel file `Config.plist` (esempio in `Config.plist.example`).

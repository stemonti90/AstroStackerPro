# AstroStackerPro

Questo repository contiene il progetto iOS dell'app **AstroStackerPro**. Se il file `AstroStackerPro.xcodeproj` non è presente, generarlo tramite [XcodeGen](https://github.com/yonaskolb/XcodeGen) eseguendo:

```bash
xcodegen generate
```

Dopo la generazione apri il progetto su Xcode 15, imposta il Bundle ID e compila su iOS 17.

Principali funzionalità della versione 1.0.0:
- Planner notturno con dati meteo e inquinamento luminoso
- Editor non distruttivo con boost delle stelle
- AI denoise, super‑resolution e derotazione automatica
- Esportazione su iCloud Drive o ShareSheet
- Localizzazione italiana/inglese tramite `Localization/` e wrapper `L()`
- Feature flags e A/B test via Firebase Remote Config

Per maggiori dettagli consulta `Docs/README.md`.



## Licenses
See [dependency licenses](Docs/QA/deps.md).

## TestFlight
Puoi unirti al programma beta tramite questo link pubblico:
<https://testflight.apple.com/join/example>
Per importare tester da CSV usa `fastlane add_testers`.

## Localization & Feature Flags
Le stringhe sono raccolte in `AstroStackerPro/Localization` e caricate con `L()`.
Gli esperimenti sono gestiti da `FeatureFlagService` con Remote Config.

## How to update screenshots
Esegui `fastlane screenshots` per generare gli screenshot nella cartella `StoreAssets/`.

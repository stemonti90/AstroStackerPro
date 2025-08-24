import SwiftUI

/// Shortcut per usare stringhe localizzate in SwiftUI come `L("start")`.
@inline(__always)
func L(_ key: String) -> LocalizedStringKey {
    LocalizedStringKey(key)
}

@inline(__always)
func L(_ key: LocalizedStringKey) -> LocalizedStringKey {
    key
}

/// Versione String per API non-SwiftUI (UIKit, log, ecc.).
@inline(__always)
func LS(_ key: String, table: String? = nil, bundle: Bundle = .main) -> String {
    NSLocalizedString(key, tableName: table, bundle: bundle, comment: "")
}

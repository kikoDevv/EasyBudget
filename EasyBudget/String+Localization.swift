import Foundation

extension String {
    var localized: String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let language: String
        if preferredLanguage.hasPrefix("nb") || preferredLanguage.hasPrefix("no") {
            language = "nb"
        } else if preferredLanguage.hasPrefix("sv") {
            language = "sv"
        } else {
            language = "en"
        }

        let path = Bundle.main.path(forResource: language, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")!
        let bundle = Bundle(path: path)!
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
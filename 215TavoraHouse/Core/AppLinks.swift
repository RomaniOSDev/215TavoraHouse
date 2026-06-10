import Foundation

enum AppLink: String {
    case privacyPolicy = "https://tavora215house.site/privacy/253"

    var url: URL? {
        URL(string: rawValue)
    }
}

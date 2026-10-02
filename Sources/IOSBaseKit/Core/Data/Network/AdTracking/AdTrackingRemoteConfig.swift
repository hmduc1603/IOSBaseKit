import Foundation

/// Shape of the `adTrackingConfig` remote config key, stored as a JSON string:
/// `{"hostUrl":"https://report.kanddlabs.com","apiKey":"<INGEST_API_KEY>"}`.
public struct AdTrackingRemoteConfig: Decodable, Sendable {
    /// Base URL of the reporting backend.
    public let hostUrl: String
    /// Shared secret matching the backend's `INGEST_API_KEY`.
    public let apiKey: String
}

public extension RemoteConfigServiceImpl {
    /// Attribution reporting backend from the `adTrackingConfig` key. Falls back to the bundled
    /// `remote_config.json` value if the fetched one is malformed, and is nil when the key is
    /// absent entirely.
    var adTrackingConfig: AdTrackingRemoteConfig? {
        let key = "adTrackingConfig"
        let candidates = [remoteConfig[key].stringValue, remoteConfig.defaultValue(forKey: key)?.stringValue]
        return candidates.lazy
            .compactMap { $0 }
            .compactMap { try? JSONDecoder().decode(AdTrackingRemoteConfig.self, from: Data($0.utf8)) }
            .first
    }
}

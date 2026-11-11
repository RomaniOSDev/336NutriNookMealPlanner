import StartAppKit

/// Per-app start values, XOR-encoded with blend 0x5A.
enum StartAppSecrets {

    /// https://336nutrinookmealplanner.site/N3Yvtn
    static var remoteFlowEntryTemplate: String {
        StartAppObfuscation.unfold([50, 46, 46, 42, 41, 96, 117, 117, 105, 105, 108, 52, 47, 46, 40, 51, 52, 53, 53, 49, 55, 63, 59, 54, 42, 54, 59, 52, 52, 63, 40, 116, 41, 51, 46, 63, 117, 20, 105, 3, 44, 46, 52], blend: 0x5A)
    }

    /// 15.11.2026
    static var calendarGateAnchor: String {
        StartAppObfuscation.unfold([107, 111, 116, 107, 107, 116, 104, 106, 104, 108], blend: 0x5A)
    }
}

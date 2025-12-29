import Foundation

public enum MockAuth {
    #if TELEGRAM_MOCK_AUTH
    public static let enabled = true
    #else
    public static let enabled = false
    #endif
}

#if TELEGRAM_MOCK_AUTH && !targetEnvironment(simulator)
#error("Mock Auth Mode is only supported on the iOS Simulator.")
#endif

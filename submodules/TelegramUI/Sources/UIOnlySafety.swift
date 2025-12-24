#if TELEGRAM_UI_ONLY && !targetEnvironment(simulator)
#error("UI_ONLY mode is simulator-only and must not run on physical devices.")
#endif

#if TELEGRAM_UI_ONLY
#warning("UI_ONLY ENABLED")
#endif


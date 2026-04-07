# Task: Environment Whitelist/Blocklist

Tests can export arbitrary variables, and our snapshot only restores those that existed before. Define an allowlist/blocklist approach so only known-safe variables survive between tests, and anything new is purged automatically unless persisted via `smokey_env_save`.

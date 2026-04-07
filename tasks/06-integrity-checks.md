# Task: Add Helper/Loader Integrity Checks

Before running a test, verify that helper and loader scripts match their known-good content (hash comparison). If mismatched, regenerate or fail fast. This stops tests from persisting malicious loader changes across the suite.

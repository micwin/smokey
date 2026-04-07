# Task: Harden State Directory Layout

Everything (helpers, loader, shared env, temp data) lives in one `.smokey-state/<run>` directory. Tests can delete or overwrite any file. Design a stricter structure (per-test subdirectories, hashed file names, limited permissions) to prevent cross-test tampering.

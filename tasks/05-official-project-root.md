# Task: Provide Official Project Root Variable

Tests compute their own `PROJECT_ROOT`, which breaks nested/temporary suites. Introduce `SMOKEY_PROJECT_ROOT` (or similar) as an explicit contract from the runner so tests don't need custom logic and can't be tricked by moving directories.

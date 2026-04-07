# Task: Process/Namespace Isolation

Tests can spawn background processes that outlive the test and disturb future runs. Explore using process groups (`setsid`) or namespaces to ensure each test runs in its own container-like scope, and the runner can clean up everything afterward.

# Task: Introduce Dedicated Runner Runtime

Smokey currently runs as a Bash script that leans on environment tricks. To achieve deterministic isolation, we need either a small runtime (Go/Python wrapper) or a structured env manager that launches tests as separate processes. Define the design for this runtime: env snapshot mechanism, process management, and how nested suites invoke the runner without shell hacks.

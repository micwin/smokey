# AGENTS

Welcome! Please follow the documented release process in `RELEASING.md` whenever you cut a Smokey release. Do **not** improvise the deployment steps; push the `release` branch and let the GitHub Actions workflow handle packaging, tagging, and publishing.

## Agent Communication

Use high semantic density for agent-to-agent messages. Keep exact facts, ids, paths, commands, errors, constraints, and requested outputs; remove filler, pleasantries, hedging, repeated framing, and long prose around simple facts. Caveman-lite is the default specialist style unless ambiguity, safety, or human-facing output requires fuller prose.

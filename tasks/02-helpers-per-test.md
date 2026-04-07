# Task: Regenerate Helpers/Loader Per Test

Helper and loader scripts are only created once per run. Tests that overwrite them (see 087/088) compromise the suite. Plan a change so each test gets fresh helper/loader files in an isolated directory, or embed the logic inside the runner so tests can't tamper with it.

# Findings during verification

The C game passed the tested state and memory checks. No game logic or memory defect was observed in these runs; this does not prove the absence of every possible defect.

Two verification issues were found and corrected:

1. The generated winner expectation files used CRLF. The shell removed the newline but retained the carriage return, so a correct `Final score` line failed comparison. The expectation files were normalized to LF. `.gitattributes` now requires LF for text files. The rerun passes all seven console scenarios.
2. The first GDB scoring script left a hardware watchpoint on a `main` stack object after `main` returned. C library exit code reused that storage and triggered a misleading watchpoint; `$_exitcode` was not yet available because execution had stopped again. The scripts now delete breakpoints/watchpoints after validating the live state and before continuing to process exit. The first log is retained as `gdb-watch-lifetime-first-run.log`; the final three logs end with explicit passing checks and normal process termination.

The debugging strategy therefore checks object lifetime as well as the value being watched. These were harness/tooling corrections, not claimed fixes to the game's scoring logic.

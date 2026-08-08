# Witco CLI Pull Request Review Prompt

You are reviewing a pull request for the Witco CLI. This project has a
constitution with NON-NEGOTIABLE principles that block merge if violated.
Conduct a thorough review in the following order, with constitution compliance
checked first.

---

## 🚫 Constitution Compliance (Merge Blockers)

**FIRST**: Read the project constitution at `.specify/memory/constitution.md` to
understand the NON-NEGOTIABLE principles.

For each NON-NEGOTIABLE principle in the constitution:

1. Search the diff for violations
2. Flag every occurrence as a merge blocker
3. Document the specific line and violation

For principles marked as requiring justification (not NON-NEGOTIABLE):

1. Flag violations for discussion
2. Request documented justification if violated

---

## 1. Correctness & Safety

- Verify the code does what it claims to do
- Ensure `unsafe` blocks are justified, minimal, and well-documented
- Look for data races, deadlocks, or unsound abstractions
- Verify error handling covers all realistic failure modes (but not hypothetical
  ones—see Simplicity)

## 2. Idiomatic Rust

**Ownership & Borrowing**

- Prefer borrowing over cloning; clone only when necessary and document why
- Use `&str` over `&String`, `&[T]` over `&Vec<T>` in function parameters
- Return owned types from constructors; accept borrowed types in methods
- Use `Cow<'_, str>` when a function may or may not need to allocate

**Pattern Matching & Control Flow**

- Prefer `match` and `if let` over chains of `if` statements for enums
- Use `match` exhaustively—avoid `_ =>` wildcards unless truly needed
- Leverage pattern guards (`if` clauses in match arms) for complex conditions
- Use `let-else` for early returns: `let Some(x) = opt else { return Err(...)
};`

**Iterators & Functional Style**

- Prefer iterator chains over manual loops where readable
- Use `collect()` with turbofish only when type can't be inferred
- Prefer `for x in &collection` over `for x in collection.iter()`
- Use `?` for all error propagation

**Type System**

- Use newtypes to distinguish semantically different values of the same
  underlying type
- Prefer enums over boolean flags for state that might expand
- Use `#[non_exhaustive]` on public enums that may gain variants
- Use the builder pattern for complex struct construction (but avoid
  over-abstraction)

## 3. Error Handling & User Experience

**Error Design (using `thiserror`)**

```rust
#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    #[error("failed to read config from '{path}'")]
    ReadFailed {
        path: PathBuf,
        #[source]
        source: io::Error,
    },
    #[error("invalid value '{value}' for key '{key}': {reason}")]
    InvalidValue {
        key: String,
        value: String,
        reason: String,
    },
}
```

**Humane Error Messages**

- Errors must be actionable: tell users _what went wrong_ and _how to fix it_
- Include relevant context: file paths, line numbers, actual vs expected values
- Suggest next steps when possible: "Did you mean...?", "Try running..."
- Use lowercase, no trailing punctuation (Rust convention)
- Chain errors with `#[source]` to preserve the full causal story

**Exit Codes**

- Use distinct exit codes for different failure categories
- Document exit codes in `--help` or man pages
- Follow sysexits.h conventions where applicable (EX_USAGE=64, EX_DATAERR=65,
  etc.)

## 4. CLI Design & Ergonomics

**Argument Parsing (clap best practices)**

```rust
/// Brief one-line description
///
/// Longer description that can span
/// multiple lines and include examples.
#[derive(Parser)]
#[command(author, version, about, long_about = None)]
#[command(propagate_version = true)]
struct Cli {
    /// Input file to process
    #[arg(short, long, value_name = "FILE")]
    input: PathBuf,

    /// Increase verbosity (-v, -vv, -vvv)
    #[arg(short, long, action = ArgAction::Count)]
    verbose: u8,
}
```

**Conventions to Enforce**

- Support `--help` and `--version` (clap provides these)
- Use `-` for stdin/stdout where appropriate
- Support `--` to separate flags from positional arguments
- Provide short flags for common options, long flags for all options
- Use consistent naming: `--dry-run` not `--dryrun` or `--dry_run`
- Group related subcommands logically

**Output & Interactivity**

- Detect TTY: use colors/progress bars only when `stdout.is_terminal()`
- Support `--color=auto|always|never` and `NO_COLOR` environment variable
- Send human-readable output to stdout, machine-readable to files/pipes
- Use stderr for progress indicators and diagnostics
- Support `-q/--quiet` to suppress non-essential output

## 5. Performance

**Allocation & Memory**

- Avoid allocations in hot paths; prefer stack allocation or arena allocators
- Use `SmallVec` or `ArrayVec` for small, bounded collections
- Pre-allocate with `Vec::with_capacity()` when size is known
- Prefer `String::new()` + `push_str()` over repeated `format!()`

**I/O Performance**

- Use `BufReader`/`BufWriter` for file I/O
- Consider memory-mapped files for large file processing
- Use `rayon` for CPU-bound parallelism where beneficial
- Batch system calls; avoid reading/writing single bytes

**Lazy Evaluation**

- Defer expensive operations until results are needed
- Use `once_cell::Lazy` or `std::sync::LazyLock` for expensive initialization
- Consider streaming/iterative processing over loading entire files into memory

## 6. Code Organization & Consistency

**Module Structure**

- One concept per module; split large files (>500 lines usually warrants review)
- Use `mod.rs` or `module_name.rs` consistently throughout the project
- Re-export public API at crate root for clean external interface
- Keep `main.rs` thin: argument parsing and orchestration only

**Naming Conventions**

- `snake_case` for functions, methods, variables, modules
- `CamelCase` for types and traits
- `SCREAMING_SNAKE_CASE` for constants
- Prefix unused variables with `_`
- Use meaningful names: `config` not `cfg`, `buffer` not `buf` (unless very
  local scope)

**Documentation**

- All public items must have doc comments
- Include examples in doc comments for non-obvious APIs
- Document panics, errors, and safety requirements
- Use `#![deny(missing_docs)]` in library crates

**Comment Quality**

- Comments explain _why_, not _what_—the code shows what it does
- Remove comments that merely restate the code (e.g., `// increment counter`
  before `i += 1`)
- Use comments for: non-obvious logic, workarounds, safety invariants,
  performance rationale
- Doc comments (`///`) for public API contracts; inline comments (`//`)
  sparingly for tricky internals
- Dead/outdated comments are worse than no comments—flag stale comments for
  removal

## 7. Testing

- Unit tests in the same file, integration tests in `tests/`
- Use `#[cfg(test)]` modules for test helpers
- Test error paths, not just happy paths
- Use `assert_cmd` and `predicates` for CLI integration tests
- Use `insta` for snapshot testing of complex output
- Prefer `proptest` or `quickcheck` for property-based testing of
  parsers/algorithms

## 8. Dependencies & Ecosystem Alignment

**Preferred Crates**

- Argument parsing: `clap` (derive macro preferred)
- Error handling: `thiserror` (per constitution—no `anyhow`)
- Serialization: `serde` with `serde_json`, `toml`, etc.
- Async runtime: `tokio` (if async is needed)
- HTTP client: `reqwest` or `ureq` (blocking)
- Logging: `tracing` (preferred) or `log` + `env_logger`
- Terminal: `crossterm`, `indicatif` (progress), `console` (styling)
- Path handling: `camino` for UTF-8 paths, `directories` for platform dirs

**Dependency Hygiene**

- Minimize dependency count; audit new dependencies
- Pin major versions, use caret requirements for minors
- Check for `unsafe`, maintenance status, and security advisories
- Prefer well-maintained crates with >1 maintainer

## Review Output Format

Before presenting findings, create a task list to track all issues discovered
during the review:

```markdown
## PR Review Task List

| #   | Title   | Location       | Severity                | Validity                           | Status  |
| --- | ------- | -------------- | ----------------------- | ---------------------------------- | ------- |
| 1   | [title] | `file.rs:line` | Blocker/High/Medium/Low | Definite/Likely/Possible/Uncertain | Pending |
| 2   | ...     | ...            | ...                     | ...                                | Pending |
```

Update the **Status** column as findings are addressed:

- **Pending** → not yet reviewed with user
- **Fixed** → user said "fix" and fix was applied
- **Won't Fix** → user said "wontfix"
- **Deferred** → user said "defer"

---

Present each finding **one at a time** in the following format, then wait for
user direction before proceeding to the next finding.

---

### Finding #[N]: [Brief title]

**Location**: `path/to/file.rs:line_number`

**Category**: [Constitution Violation | Constitution Concern | Critical Issue |
Suggestion]

**Code**:

```rust
// The relevant code snippet
```

**Issue**: [Clear explanation of what's wrong]

**Severity**: [Blocker | High | Medium | Low]

- **Blocker**: Violates NON-NEGOTIABLE constitution principle—cannot merge
- **High**: Correctness, safety, or significant maintainability issue
- **Medium**: Code quality, idiom violation, or minor bug risk
- **Low**: Style, naming, or minor improvement opportunity

**Validity**: [Definite | Likely | Possible | Uncertain]

- **Definite**: Clearly violates a rule or is objectively incorrect
- **Likely**: Strong evidence this is a problem
- **Possible**: May be an issue depending on context
- **Uncertain**: Flagging for discussion; may be a false positive

**Possible Solutions**:

1. [First option with code example if helpful]
2. [Alternative approach if applicable]

**Recommended Disposition**: [Must Fix | Should Fix | Consider | Discuss]

- **Must Fix**: Blocker + Definite/Likely → cannot proceed without addressing
- **Should Fix**: High severity or clear improvement
- **Consider**: Valid point but reasonable to defer or decline
- **Discuss**: Needs author input to determine best path

---

After presenting each finding, use the **AskUserQuestionTool** to get the user's
decision:

```
Question: "Finding #[N]: [Brief title] - How should I proceed?"
Options: ["fix", "wontfix", "defer", "discuss"]
```

Based on the user's response:

- **"fix"** → Implement the recommended solution (or ask which solution if
  multiple), then update task list status to **Fixed**
- **"wontfix"** → Update task list status to **Won't Fix**, move to the next
  finding
- **"defer"** → Update task list status to **Deferred**, move to the next
  finding
- **"discuss"** → Provide more context or alternative perspectives, then ask
  again

After each response, show the updated task list before presenting the next
finding.

Continue presenting findings in this order:

1. Constitution Violations (Blockers) — all of these first
2. Constitution Concerns
3. Critical Issues
4. Suggestions (only if user wants them)

At the end, provide a summary of:

- Total findings by category
- Findings addressed vs. declined
- Any remaining blockers

---

**Review Checklist** (verify before approving):

- [ ] All NON-NEGOTIABLE principles in `.specify/memory/constitution.md` are
      satisfied
- [ ] All other constitution principles are satisfied or have documented
      justification
- [ ] CI passes all required checks

When reviewing, be constructive and assume good intent. Focus on teaching and
improving, not just finding faults.

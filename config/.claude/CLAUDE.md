# CLAUDE.md

## Voice

- No praise or flattery
- Always provide pull request descriptions, templates, documentation, and similar content as raw markdown.
- Any writing you generate should not contain empty claims, business speak, marketing speak, verbose bloviation, or speculation.
- Be pithy, precise, and accurate.
- Be as succinct as possible without omitting critical meaning and context.
- Don't be obsequious or attempt to sound human. Accept commands without comment and give answers without commentary.
- Don't overuse bulleted lists where prose is suitable.
- Don't sound like you're trying to sell something.
- Use active voice.
- Use simple, clear language.

## Writing Style

### Construction

Prefer direct construction. Say what something is or does, not how it goes about
doing it. "We improve X with Y" over "We improve X by doing Y." The first
presents a fact. The second narrates a process. Unless the process is the point,
cut to the fact.

Use active voice. The subject acts; it isn't acted upon. "We deliver
notifications when needed" not "Notifications are delivered when needed."

Lead with the positive. State what we do before stating what we don't. When a
contrast is necessary, earn it — name the thing we do, then name what it
replaces. Don't open with a rejection.

### Word Choice

Use the right word. If a precise term communicates the idea better than a common
one, use it. Don't simplify to the point of vagueness, and don't complicate to
the point of showing off.

Avoid jargon that performs expertise without adding meaning. "Leverage,"
"utilize," "facilitate," "enable," "empower" — these words pad sentences without
sharpening them.

Be specific. "Notifications arrive when relevant" is weaker than "notifications
arrive when the user is working in that area of the product." Precision builds
credibility.

### Tone

Confident, not arrogant. We believe in what we're building. That belief comes
through in directness, not in superlatives or claims about being the best.

Warm, not casual. We care about the reader. That shows in clarity and respect
for their time, not in exclamation marks, emoji, or forced friendliness.

Opinionated, not combative. We disagree with the prevailing model. We say so
plainly. We don't mock it, dwell on it, or define ourselves by opposition to it.

### Brevity

Every sentence should earn its place. If a paragraph works without a sentence,
cut the sentence. If a sentence works without a word, cut the word.

Don't narrate what you're about to say. "It's worth noting that..." "It's
important to understand that..." — these are throat-clearing. Start with the
thing itself.

Don't repeat an idea in different words within the same section. State it once,
well.

## Code

- Prefer functional over object oriented programming

## Tasks

- When starting work on a new ticket, first create a branch from up-to-date main
- Ensure tests are passing for each change
- Implement changes in SMALL, atomic changes, committing between
- Add tests when appropriate
- Never commit changes for one ticket on second ticket's branch

## Branching

- Format: `{type}/gh-{issue-number}-{human-readable-short-description}` (e.g. `feat/gh-78-automate-homebrew-tap`)
- Use kebab-case for all branch names
- Prefix branch name with Conventional Commit type, e.g. `fix/*`, `feat/*`, `ci/*`
- Ask for ticket reference if not provided
- Create new branch from repo's default branch for each ticket (Linear, Jira, GitHub)
- Ensure default branch is up-to-date first
- Create new branches from `main` (or default branch), pull before branching
- Warn if working on new task in main/master/wrong branch
- Suggest new branch from default
- Pull with rebase for new branches
- Use Atlassian CLI `acli` to interact with Jira.

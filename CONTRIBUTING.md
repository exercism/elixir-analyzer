# Contributing

Automated Mentoring support for the Elixir track is a work in progress, and
it's not uncommon that people discover incorrect analysis, have a better
approach on detecting certain code paths, report missing edge cases, factual
errors, logical errors and develop new analysers.

We welcome contributions of all sorts and sizes, from reporting issues to
submitting patches, as well as joining the current [💬 discussions][issue-discussion].

-----

This guide covers several common scenarios pertaining to **improving the
Elixir analyzer**. There are several other guides about contributing to
other parts of the Exercism ecosystem.

* [The Elixir track][contributing-elixir]
* [Project Automated Mentoring Support][contributing-automated-mentoring-support]
* [The Elixir Analyzer][contributing-elixir-analyzer]

## Code of Conduct

Help us keep Exercism welcoming. Please read and abide by the [Code of Conduct][coc].

## Analyzers

Before contributing code to any existing analyzer or any new analyzer, please
have a thorough look at the current analyzers and dive into [the interface][docs-interface]
and general [analyzer guidelines][docs-guidelines].

### New exercise / analyzer

Let's say you want to write a new analyzer, because you've noticed that this
exercise could benefit from automated mentoring support, or just because you
find this interesting, the first step is to [check for an open issue][issue-new-exercise].
If it's there, make sure no one is working on it, and most of all that there is
not an open Pull Request towards this exercise.

If there is no such issue, you may open one. Take [this problem spec][sample-twofer]
as a baseline of what should be in it. This serves as a starting point for
all discussion, as we now must establish a few things before starting to write
code.

#### Project Track Anatomy

If the exercise has undergone at least phase 1 of Project Track Anatomy, it is
likely that there are [mentoring notes][mentor-notes]. These are likely to
contain what the _maintainers_ of the JavaScript track _or_ the dedicated people
from the track anatomy project deem to be the set of reasonable solutions.

#### Abstract Syntax Approach

These solutions will be your baseline for `approve`, one of the expected
outputs. The Elixir analyzer takes an abstract syntax tree approach to look for
features in the problem submission to then return feedback to determine whether
it should be approved or disapproved.

#### Discussion 💬 and Samples

In your issue, write out how you're going to tackle the initial set of
solutions, and work on a prototype. If there are no `fixtures` yet, we will
supply you with a set of fixtures (500, if there are at least 500 submissions)
so you can run your analyzer using `batch.sh slug` on these fixtures.

It can be very fruitful to ask current maintainers and previous authors of
analyzers how to tackle various approaches, especially since there are so many
ways to write equivalent code in Elixir.

#### Writing comments

Comments are the output of the Analyzer. You don't need to be a great writer in
order to contribute to the analyzers. How this works inside the repository is
a guide on its own: read more about [📝 Comments][docs-comments].

#### Tests

While no formal CI testing is done, would welcome a framework to integrate it in
to the workflow.  Most exercism CI is done with TravisCI.

### Sync with exercise

<!-- Explain that syncs in problem-descriptions need to be synced with the analyzers,
     establish the set of rules how to update, but wait until there is proper
     versioning and how that is given at runtime -->

This section will be written once there is consensus on how the input will be
versioned. Until then, the steps are the same as for writing a new analyzer,
except that you may skip creating an issue.

### Add new behaviour

<!-- Adding new tests is mandatory -->

This section will be written once there is consensus on coverage and tests in
general.

### Commentary copy

This section will be written once there is consensus on how the commentary is
structured in `website-copy` and what the format for parameters/templates is
like.

Find all _technical_ details in [the doc about 📝 Comments][docs-comments].

## Tools

We use various tools to maintain this repository and this analyzer. In order
to contribute to the _code_ of this track, you'll need Elixir 1.9.1 or higher.

### `analyze` (.sh, .bat)

```shell
# not yet built, but plan for this to be the
./bin/analyze.sh two-fer ~/folder/to/solution
```

This runs the analyzer using `two-fer` as exercise and a path to a solution.
Most scripts, including this one, accept a wide range of flags to change or
enhance the behaviour, as coded in [`elixir_analyzer/cli.ex`][file-execution-options].

<!-- Run with the `-h` / `--help` flag to get a list of flags and their description.

```shell
./bin/analyze.sh --help
``` -->

<!--

### `remote` (.sh, .bat)

```shell
./bin/remote.sh https://exercism.io/tracks/javascript/exercises/two-fer/solutions/df3bb5d7131c44ea9c62206cc8d6c225 -dcp --dry
```

You need the [`exercism` cli][cli] in order for this to work. It takes an
_exercism solution url_. and downloads it using the `exercism` cli. It then
runs the analyzer on it.

You'll most likely want `-dcp --dry` (`--debug`, `--pretty`, `--console` and
`dry run`) during development, which enables console output (instead of
`stdout`/`stderr`), shows `logger.log` as well as `logger.error` and
`logger.fatal`, pretty prints the JSON output and disables writing the output
to `analysis.json`.

You can pass the following type of URLs:

- Published solutions: `/tracks/javascript/exercises/<slug>/<id>`
- Mentor solutions: `/mentor/solutions/<id>`
- Your solutions: `/my/solutions/<id>`
- Private solutions: `/solutions/<id>`

If you wish to _preview_ the actual messages, pass in `--noTemplates` to use
the analyzer `Comment`Factories to generate actual messages. If the comment
factories are kept in-sync with `website-copy`, it will be the exact same
output as on the site.

-->

[cli]: https://github.com/exercism/cli
[contributing-elixir]: https://github.com/exercism/elixir/blob/master/CONTRIBUTING.md
[contributing-elixir-analyzer]: https://github.com/exercism/elixir-analyzer/blob/master/CONTRIBUTING.md
[contributing-automated-mentoring-support]: https://github.com/exercism/automated-mentoring-support/
[coc]: https://exercism.io/code-of-conduct
[docs-interface]: https://github.com/exercism/automated-mentoring-support/blob/master/docs/interface.md
[docs-guidelines]: https://github.com/exercism/automated-mentoring-support/blob/master/docs/guidelines.md
[issue-discussion]: https://github.com/exercism/elixir-analyzer/issues?q=is%3Aopen+is%3Aissue+label%3A%22discussion%22%3Aspeech_balloon%3A
[issue-new-exercise]: https://github.com/exercism/elixir-analyzer/labels/new%20exercise%20%3Asparkles%3A
[mentor-notes]: https://github.com/exercism/website-copy/tree/master/tracks/javascript/exercises

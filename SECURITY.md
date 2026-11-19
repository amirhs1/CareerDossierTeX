# Security policy

CareerDossierTeX is a set of LuaLaTeX document classes and packages. A
vulnerability here is a way for its files, or a document built with them, to
do something the person compiling it did not ask for: run a program, read or
write a file outside the build, or reach the network. A layout or extraction
defect is a bug, and goes in an ordinary issue.

## Reporting a vulnerability

Report it privately, through GitHub's private vulnerability reporting:

1. Open the repository's **Security** tab.
2. Choose **Report a vulnerability**.
3. Fill in the advisory form.

The report is visible only to you and the maintainer until the maintainer
publishes an advisory. Do not open a public issue, pull request, or discussion
that describes the problem.

If the **Report a vulnerability** button is not there, private reporting is not
yet turned on for the repository. Open a public issue that asks for a private
channel and gives no detail of the problem, and wait for the reply.

## What to include

- the release or commit you used, and your TeX distribution and its version;
- a minimal document that shows the problem, and the command that compiles it;
- what happened, and what you expected instead.

## Scope

Reports about the files `manifest.txt` lists under "The Work", the examples,
and the build and test scripts in this repository are in scope. A problem in
LuaLaTeX, a TeX distribution, or a package this toolkit loads belongs to that
project; report it there.

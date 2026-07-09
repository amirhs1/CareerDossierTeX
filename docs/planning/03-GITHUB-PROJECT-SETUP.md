# GitHub Project Setup Guide

## 1. What a GitHub Project should represent

Create one GitHub Project for the entire repository:

```text
CareerDossierTeX Development
```

Do not create a separate Project for every release. Use milestones and project views to separate phases.

A GitHub Project tracks issues, pull requests, and planning items. It can display the same work as a table, board, or roadmap.

Official documentation:

- https://docs.github.com/issues/planning-and-tracking-with-projects
- https://docs.github.com/issues/planning-and-tracking-with-projects/learning-about-projects/quickstart-for-projects

## 2. Create the Project in the GitHub interface

1. Open your GitHub profile or organization.
2. Open **Projects**.
3. Select **New project**.
4. Choose a blank project.
5. Name it `CareerDossierTeX Development`.
6. Add a description:
   `Planning and release tracking for the CareerDossierTeX XeLaTeX class and package repository.`
7. Link the repository when GitHub offers the repository-selection option.

## 3. Create custom fields

### Status

Use the built-in Status field or configure:

```text
Backlog
Ready
In progress
In review
Done
```

Meaning:

- **Backlog**: accepted idea, not scheduled for immediate work.
- **Ready**: sufficiently defined and available to start.
- **In progress**: active branch or implementation.
- **In review**: open pull request, awaiting checks or review.
- **Done**: merged or otherwise completed.

### Phase

Create a single-select field:

```text
Phase 0 — Inventory
Phase 1 — Industry
Phase 2 — Academic
Phase 3 — Languages
Phase 4 — Expansion
Phase 5 — Stable API
```

### Priority

Create:

```text
P0 — Release blocker
P1 — Important
P2 — Normal
P3 — Optional
```

Use `P0` sparingly. A P0 issue blocks the current release.

### Size

Create:

```text
XS
S
M
L
```

Suggested interpretation:

- **XS**: one small edit or documentation correction.
- **S**: a focused change with one test.
- **M**: several files or one meaningful feature.
- **L**: should probably be split into sub-issues.

### Start date and Target date

Use date fields mainly for:

- parent issues;
- release preparation;
- roadmap visualization.

Do not spend time assigning dates to every tiny issue.

### Parent issue and Sub-issue progress

Enable the built-in fields when available. These make the relationship between an epic and its sub-issues visible in the Project.

Official documentation:

- https://docs.github.com/issues/planning-and-tracking-with-projects/understanding-fields/about-parent-issue-and-sub-issue-progress-fields

## 4. Create project views

### View A: Tonight — v0.1.0

Layout:

```text
Board
```

Group by:

```text
Status
```

Filter:

```text
milestone:"v0.1.0 — English Industry Dossier"
```

Display:

- Priority;
- Size;
- Assignee;
- Milestone.

Use this view while implementing Phase 1.

### View B: All Work

Layout:

```text
Table
```

Group by:

```text
Phase
```

Display:

- Status;
- Milestone;
- Priority;
- Size;
- Parent issue;
- Assignee.

This is the best administrative view.

### View C: Roadmap

Layout:

```text
Roadmap
```

Use:

- Start date;
- Target date.

Show mainly parent issues and large release work. Avoid placing every small sub-issue on the roadmap.

Official documentation:

- https://docs.github.com/issues/planning-and-tracking-with-projects/customizing-views-in-your-project/customizing-the-roadmap-layout

### View D: Bugs and Technical Debt

Layout:

```text
Table
```

Filter:

```text
label:type:bug,technical-debt
```

Group by:

```text
Status
```

## 5. Configure project automation

Enable available built-in workflows:

- Automatically add new issues from the repository.
- Automatically add pull requests from the repository.
- Set newly added items to `Backlog`.
- Set closed issues to `Done`.
- Set merged pull requests to `Done`.
- Return reopened issues to `In progress` or `Ready`.

Use an auto-add filter scoped to the repository rather than adding every item from every repository on your account.

Official documentation:

- https://docs.github.com/issues/planning-and-tracking-with-projects/automating-your-project/adding-items-automatically

## 6. How to move an item through the Project

Example issue lifecycle:

```text
Backlog
  → Ready
  → In progress
  → In review
  → Done
```

Practical actions:

1. Refine the issue and give it acceptance criteria.
2. Move it to `Ready`.
3. Create a branch.
4. Move it to `In progress`.
5. Open a draft pull request.
6. When implementation is ready, mark the PR ready for review.
7. Move the issue or PR to `In review`.
8. Wait for GitHub Actions to pass.
9. Merge the PR.
10. Confirm the linked issue closes and moves to `Done`.

## 7. What not to duplicate

Do not create custom Project fields for data GitHub already tracks.

Avoid:

- custom Assignee field;
- custom Milestone field;
- custom Label field;
- custom Pull Request field;
- priority labels when a Priority field exists;
- status labels when a Status field exists.

Use:

- GitHub milestones for releases;
- labels for categories;
- project fields for planning metadata;
- assignees for responsibility.

## 8. Recommended daily Project habit

At the beginning of a work session:

1. Open `Tonight — v0.1.0` or the current milestone view.
2. Select one `Ready` issue.
3. Confirm it has acceptance criteria.
4. Move it to `In progress`.
5. create a branch.

At the end:

1. Push your work.
2. Open or update the pull request.
3. Record unfinished points in the PR or issue.
4. Move the item to the correct status.
5. Do not leave completed work marked `In progress`.


# Git Flow - Working Methodology

This document describes the **Git Flow** methodology applied to the Air Quality Platform project to maintain an organized and collaborative workflow.

## 🌳 Branch Structure

### Main Branches

#### `main`
- **Production** branch
- Contains stable and tested code
- Only updated via merge from `develop` or `hotfix`
- Every commit in `main` must be tagged with a version (e.g., `v1.0.0`, `v1.1.0`)

#### `develop`
- **Integration and development** branch
- Contains the latest completed features
- Base for creating new feature branches (`feature`)
- Merged into `main` when preparing a release

### Supporting Branches

#### `feature/*`
- For developing **new features**
- Created from `develop`
- Merged back into `develop`
- Naming: `feature/descriptive-name`
  - Example: `feature/citizen-dashboard`
  - Example: `feature/air-quality-endpoints`

#### `release/*`
- For preparing a **new production version**
- Created from `develop`
- Allows minor fixes and metadata preparation
- Merged into `main` and `develop`
- Naming: `release/v1.x.x`
  - Example: `release/v1.0.0`

#### `hotfix/*`
- For **urgent fixes** in production
- Created from `main`
- Merged into `main` and `develop`
- Naming: `hotfix/short-description`
  - Example: `hotfix/fix-login-error`

## 🔄 Workflows

### 1. Develop a New Feature

```bash
# Make sure you are on the updated develop branch
git checkout develop
git pull origin develop

# Create a new feature branch
git checkout -b feature/feature-name

# Develop your feature
# Make descriptive commits
git add .
git commit -m "feat: clear description of the change"

# When finished, update develop and merge
git checkout develop
git pull origin develop
git merge feature/feature-name

# Push the changes
git push origin develop

# Delete the feature branch (optional)
git branch -d feature/feature-name
```

### 2. Prepare a Release

```bash
# From develop, create a release branch
git checkout develop
git checkout -b release/v1.0.0

# Make final adjustments (versions, changelog, etc.)
git commit -m "chore: prepare release v1.0.0"

# Merge into main
git checkout main
git merge release/v1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0"

# Merge back into develop
git checkout develop
git merge release/v1.0.0

# Push changes and tags
git push origin main
git push origin develop
git push origin v1.0.0

# Delete the release branch
git branch -d release/v1.0.0
```

### 3. Apply a Hotfix

```bash
# From main, create a hotfix branch
git checkout main
git checkout -b hotfix/fix-critical-bug

# Fix the issue
git commit -m "fix: fix critical production error"

# Merge into main
git checkout main
git merge hotfix/fix-critical-bug
git tag -a v1.0.1 -m "Hotfix version 1.0.1"

# Merge into develop
git checkout develop
git merge hotfix/fix-critical-bug

# Push changes
git push origin main
git push origin develop
git push origin v1.0.1

# Delete the hotfix branch
git branch -d hotfix/fix-critical-bug
```

## 📝 Commit Conventions

Use the **Conventional Commits** format for clear messages:

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

### Commit Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Formatting changes (no logic impact)
- **refactor**: Code refactoring
- **test**: Add or modify tests
- **chore**: Maintenance tasks (dependencies, configs)
- **perf**: Performance improvements

### Examples

```bash
git commit -m "feat(backend): add air quality endpoints for citizen dashboard"
git commit -m "fix(frontend): resolve login validation error"
git commit -m "docs: update README with installation instructions"
git commit -m "refactor(ingestion): apply adapter pattern for external APIs"
```

## 🎯 Best Practices

1. **Never work directly on `main` or `develop`**
   - Always create a support branch

2. **Keep branches updated**
   - Run `git pull` regularly from `develop`

3. **Small and frequent commits**
   - Makes reviewing and reverting changes easier

4. **Clearly describe your changes**
   - Use descriptive commit messages

5. **Review before merging**
   - Check for conflicts
   - Make sure the code works

6. **Delete obsolete branches**
   - Keep the repository clean

7. **Tag versions**
   - Use semantic versioning (`MAJOR.MINOR.PATCH`)

## 🔍 Useful Commands

```bash
# List all branches
git branch -a

# Show current status
git status

# Show commit history
git log --oneline --graph --all

# Switch between branches
git checkout branch-name

# Create and switch to a new branch
git checkout -b new-branch-name

# Update current branch
git pull origin branch-name

# Show differences
git diff

# Show merged branches
git branch --merged
```

## 📚 References

- [Git Flow Original](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

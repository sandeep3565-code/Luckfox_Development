# Branch Protection & Merge Rules

This document outlines the branch protection rules and commit blockers configured for this repository.

## Overview

```
main (production)
  ↑ (merge only from develop, bugfix)
  ├─ develop
  │  ↑ (merge only via PR, user approval required)
  │  ├─ feature/* (create from develop, merge via PR)
  │  └─ bugfix/* (create from develop, merge via PR)
  │
  └─ bugfix/* (create from main for critical fixes, merge via PR)
```

---

## Branch Rules

### 🔴 Main Branch (`main`)

**Who can commit:**
- ✅ Only `sandeep3565-code` (repository owner)
- ❌ No direct commits from other users

**Merge Rules:**
- ✅ Merges allowed ONLY from:
  - `develop` branch
  - `bugfix/*` branches
- ✅ MUST be via Pull Request
- ✅ REQUIRES PR approval from code owner
- ✅ All status checks must pass
- ❌ Direct commits BLOCKED for all users except owner

**Protected:** YES

---

### 🟢 Develop Branch (`develop`)

**Who can commit:**
- ✅ Only `sandeep3565-code` (repository owner)
- ❌ No direct commits from other users

**Merge Rules:**
- ✅ Merges allowed from:
  - `feature/*` branches
  - `bugfix/*` branches (created from develop)
- ✅ MUST be via Pull Request
- ✅ REQUIRES PR approval from code owner
- ✅ All status checks must pass
- ❌ Direct commits BLOCKED for all users except owner
- ❌ Merge blocked until PR is accepted

**Protected:** YES

---

### 🔵 Feature Branches (`feature/*`)

**Who can commit:**
- ✅ Branch creator and assigned developers
- ✅ All contributors can work on feature branches

**Merge Rules:**
- ✅ Merge to `develop` via Pull Request
- ✅ REQUIRES approval from code owner

**Naming Convention:**
```
feature/feature-name
feature/JIRA-123-feature-description
```

---

### 🟠 Bugfix Branches (`bugfix/*`)

**Who can commit:**
- ✅ Branch creator and assigned developers

**Merge Rules:**
- ✅ Can be created from:
  - `develop` → Merge to `develop` via PR
  - `main` → Merge to `main` via PR (for critical production fixes)
- ✅ REQUIRES approval from code owner

**Naming Convention:**
```
bugfix/bug-name
bugfix/JIRA-123-bug-description
```

---

## Setup Instructions

### For Repository Owner (sandeep3565-code)

1. Go to your repository on GitHub
2. Click **Settings** → **Branches**
3. Follow the setup steps below

---

## GitHub Configuration Steps

### Step 1: Protect Main Branch

1. Go to **Settings** → **Branches**
2. Click **Add rule**
3. Configure:
   - **Branch name pattern:** `main`
   - ✅ **Require a pull request before merging**
     - Require approvals: `1` (from code owner)
     - Dismiss stale pull request approvals when new commits are pushed: ✅
   - ✅ **Require status checks to pass before merging**
     - Require branches to be up to date before merging: ✅
   - ✅ **Include administrators** (optional but recommended)
   - ✅ **Restrict who can push to matching branches**
     - Allow only: `sandeep3565-code`
   - ✅ **Require branches to be up to date before merging**
4. Click **Create**

### Step 2: Protect Develop Branch

1. Go to **Settings** → **Branches**
2. Click **Add rule**
3. Configure:
   - **Branch name pattern:** `develop`
   - ✅ **Require a pull request before merging**
     - Require approvals: `1` (from code owner)
     - Dismiss stale pull request approvals when new commits are pushed: ✅
   - ✅ **Require status checks to pass before merging**
     - Require branches to be up to date before merging: ✅
   - ✅ **Include administrators** (optional but recommended)
   - ✅ **Restrict who can push to matching branches**
     - Allow only: `sandeep3565-code`
   - ✅ **Require branches to be up to date before merging**
4. Click **Create**

---

## Allowed Workflows

### Creating a Feature Branch (Team Member)

```bash
# Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/my-feature-name
git push origin feature/my-feature-name

# Make commits, then create PR on GitHub
# PR will be merged after code owner approval
```

### Creating a Bugfix Branch (Team Member)

```bash
# For bugs in develop
git checkout develop
git pull origin develop
git checkout -b bugfix/bug-name
git push origin bugfix/bug-name

# For critical bugs in main
git checkout main
git pull origin main
git checkout -b bugfix/critical-bug-name
git push origin bugfix/critical-bug-name

# Create PR for review and merge
```

### Direct Commit (Owner Only)

```bash
git checkout main
git pull origin main
git commit -m "fix: critical fix"
git push origin main
```

---

## Blocked Scenarios

| Scenario | Status | Reason |
|----------|--------|--------|
| Team member commits directly to `main` | ❌ BLOCKED | Branch protection + push restriction |
| Team member commits directly to `develop` | ❌ BLOCKED | Branch protection + push restriction |
| Merge to `main` without PR | ❌ BLOCKED | Require PR before merge |
| Merge to `main` without approval | ❌ BLOCKED | Require code owner approval |
| Merge to `develop` without PR | ❌ BLOCKED | Require PR before merge |
| Merge from non-allowed branch to `main` | ❌ BLOCKED | Restricting allowed source branches |
| PR merge before status checks pass | ❌ BLOCKED | Require passing status checks |

---

## FAQ

**Q: How do I merge my feature branch to develop?**
A: Push your feature branch and create a Pull Request on GitHub. Wait for code owner approval, then merge.

**Q: What if I need to fix something in the main branch?**
A: Create a `bugfix/*` branch from `main`, push it, and create a PR. Only the code owner can merge it.

**Q: Can I force push to develop?**
A: No, branch protection prevents force pushes. Contact the code owner if you need to revert changes.

**Q: What if the code owner needs to make a quick fix?**
A: Owner can commit directly to main or develop (they're exempt from the push restriction).

---

## Code Owner

- **GitHub Handle:** `sandeep3565-code`
- **Email:** `sandeep.kumar@matrixcomsec.com`

All PR approvals for `main` and `develop` merges must come from the code owner.

---

**Last Updated:** 6 May 2026

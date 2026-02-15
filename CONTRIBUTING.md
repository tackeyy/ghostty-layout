# Contributing to ghostty-layout

Thank you for your interest in contributing to ghostty-layout! This document provides guidelines and instructions for contributing to the project.

## Welcome

ghostty-layout is a CLI tool for splitting Ghostty terminal panes from the command line. We welcome contributions from everyone, whether you're fixing a bug, adding a feature, or improving documentation.

## Table of Contents

- [Ways to Contribute](#ways-to-contribute)
- [Before You Start](#before-you-start)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Submitting Changes](#submitting-changes)
- [Code Review Process](#code-review-process)
- [Community Guidelines](#community-guidelines)
- [Getting Help](#getting-help)

## Ways to Contribute

### You can contribute by:

- **Reporting bugs** - Found an issue? Let us know!
- **Suggesting features** - Have an idea? We'd love to hear it
- **Improving documentation** - Help make our docs clearer
- **Submitting bug fixes** - Fix issues and help improve stability
- **Adding new features** - Expand ghostty-layout's capabilities (discuss first!)

## Before You Start

1. **Check existing issues/PRs** to avoid duplication
2. **For new features**, open an issue first to discuss the proposal
3. **Read our [Testing Guide](docs/TESTING.md)** to understand our testing approach
4. **Ensure you understand our [Code of Conduct](CODE_OF_CONDUCT.md)**

## Development Setup

### Prerequisites

- macOS 13+ (Ventura or later)
- Swift 5.9+
- Xcode 15+ (or Swift toolchain)
- [Ghostty](https://ghostty.org/) terminal installed (for manual testing)

### Setup Steps

```bash
# 1. Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/ghostty-layout.git
cd ghostty-layout

# 2. Build the project
swift build

# 3. Run tests to verify setup
swift test

# 4. Build a release binary
swift build -c release

# 5. Test the CLI locally
.build/release/ghostty-layout --version
```

> **Note:** Accessibility permissions are required to run ghostty-layout against a live Ghostty instance. Tests do not require this permission.

## Coding Standards

### Swift Style

- Follow [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- Use `let` over `var` wherever possible
- Use descriptive variable names (`gridLayout` not `gl`)
- Add access control modifiers (`public`, `internal`, `private`)
- Use protocol-oriented design for testability (e.g., `KeySending` protocol)

### Code Organization

- Keep functions small and focused (single responsibility)
- Extract complex logic into separate functions
- Add comments only when logic isn't self-evident
- Follow existing patterns in the codebase
- Place public API in `Sources/GhosttyLayoutLib/`
- Place the CLI entry point in `Sources/ghostty-layout/`

### Commit Message Convention

Format: `<type>: <subject>`

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `test:` Test additions/changes
- `docs:` Documentation changes
- `refactor:` Code refactoring (no functional changes)
- `chore:` Maintenance tasks (dependencies, tooling)

**Examples:**
```
feat: add support for custom grid ratios
fix: correct key code mapping for arrow keys
test: add edge case tests for GridLayout.parse
docs: update README with new --sync-config flag
refactor: extract config validation to separate method
chore: update swift-argument-parser to 1.4.0
```

## Testing Requirements

**All code contributions MUST include tests.**

### Test Types

1. **Layout Tests** - Test grid parsing, description, and execution sequences
2. **Config Tests** - Test configuration data structures and serialization
3. **Parser Tests** - Test Ghostty config file parsing
4. **KeySender Tests** - Test modifier key mapping
5. **FileHelper Tests** - Test file security and symlink handling

### Running Tests

```bash
# Run all tests
swift test

# Run a specific test class
swift test --filter GridLayoutTests

# Run a specific test method
swift test --filter GridLayoutTests.testParseH
```

### Test Writing Guidelines

- Follow **Arrange/Act/Assert** pattern
- One assertion per test when possible
- Use descriptive test names: `testParseInvalidFormatReturnsNil`
- Use `MockKeySender` for testing execution sequences
- See **[docs/TESTING.md](docs/TESTING.md)** for comprehensive testing guide

### Test Coverage Expectations

- **New features**: Tests for all new code paths
- **Bug fixes**: Add regression test reproducing the bug
- **Refactoring**: Maintain or improve existing coverage

## Submitting Changes

### Pull Request Process

#### 1. Create a branch

```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

#### 2. Make your changes

- Write code
- Add tests
- Update documentation if needed

#### 3. Ensure quality

```bash
swift test          # All tests must pass
swift build         # Build must succeed
```

#### 4. Commit your changes

```bash
git add .
git commit -m "feat: add your feature description"
```

#### 5. Push and create PR

```bash
git push origin feat/your-feature-name
# Then create PR via GitHub UI
```

#### 6. Fill out PR template

- Describe what changed and why
- Link related issues with `Closes #123`
- Provide testing evidence
- Check all applicable boxes in the template

### PR Requirements Checklist

Before submitting, ensure:

- All tests pass (`swift test`)
- Build succeeds (`swift build`)
- Code follows project style
- Commit messages follow convention
- Tests added for new functionality
- Documentation updated (if applicable)
- PR template fully completed

### What to Expect

- **Initial review** within 2-3 business days
- **Feedback** and requested changes from maintainers
- **Approval and merge** once all requirements are met

## Code Review Process

### For Contributors

- **Be responsive** to feedback and questions
- **Ask for clarification** if feedback is unclear
- **Push updates** to the same branch (PR will auto-update)
- **Be patient and respectful** throughout the process

### Review Criteria

Reviewers will check:

- **Functionality** - Does it work as intended?
- **Tests** - Are they comprehensive and passing?
- **Code Quality** - Is it readable and maintainable?
- **Documentation** - Is it clear and up-to-date?
- **Performance** - Are there any obvious performance issues?
- **Security** - Are there any potential vulnerabilities?

## Community Guidelines

- Be respectful and welcoming to all contributors
- Follow our [Code of Conduct](CODE_OF_CONDUCT.md)
- Provide constructive feedback
- Assume good intentions
- Help others learn and grow

## Getting Help

- **Questions** - Open a [GitHub Discussion](https://github.com/tackeyy/ghostty-layout/discussions)
- **Bug Reports** - Open an [Issue](https://github.com/tackeyy/ghostty-layout/issues/new?template=bug_report.yml)
- **Feature Requests** - Open an [Issue](https://github.com/tackeyy/ghostty-layout/issues/new?template=feature_request.yml)
- **General Questions** - Open an [Issue](https://github.com/tackeyy/ghostty-layout/issues/new?template=question.yml)

## Recognition

All contributors are recognized in:

- GitHub Contributors page
- Release notes (for significant contributions)

---

Thank you for contributing to ghostty-layout! Your efforts help make this tool better for everyone.

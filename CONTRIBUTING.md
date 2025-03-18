# Contributing to ZeatMap

Thank you for your interest in contributing to ZeatMap! This document provides guidelines on how to contribute effectively.

## Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for our commit messages. This allows us to automatically generate release notes and determine the next semantic version number.

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `build`: Changes that affect the build system or external dependencies
- `ci`: Changes to our CI configuration files and scripts
- `chore`: Other changes that don't modify src or test files

### Examples

```
feat: add date navigation controls

This adds previous/next month buttons to the ZeatMap widget.
```

```
fix(rendering): resolve overflow issue in grid layout

Closes #123
```

```
docs: update API documentation with examples
```

### Breaking Changes

If your change introduces a breaking API change, include `BREAKING CHANGE:` in the footer followed by a description:

```
feat: change ZeatMapItem API to support multiple values

BREAKING CHANGE: ZeatMapItem.value now accepts a list instead of a single value
```

## Pull Request Process

1. Ensure your code passes all tests: `flutter test`
2. Verify there are no analysis issues: `flutter analyze`
3. Format code properly: `flutter format lib test example`
4. Update documentation if needed
5. Update CHANGELOG.md with changes
6. Request review from at least one team member

## Development Workflow

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Run tests and analysis
5. Submit a pull request

Thank you for contributing to ZeatMap!
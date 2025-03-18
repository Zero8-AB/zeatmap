# Release Process for ZeatMap

## Automated Semantic Versioning Process

ZeatMap now uses semantic versioning with automated releases using the [semantic-release-pub](https://github.com/zeshuaro/semantic-release-pub) plugin.

### How It Works

1. When code is merged to the `main` or `master` branch, the GitHub Actions workflow automatically:
   - Analyzes commit messages
   - Determines the next version number
   - Updates the CHANGELOG.md
   - Updates the version in pubspec.yaml
   - Creates a GitHub release
   - Tags the release in Git

### Commit Message Format

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for all commit messages:

```
<type>(<scope>): <description>
```

Common types:
- `feat`: New feature (minor version bump)
- `fix`: Bug fix (patch version bump)
- `docs`: Documentation changes (no version bump)
- `chore`: Routine tasks (no version bump)
- `refactor`: Code changes that neither fix a bug nor add a feature (no version bump)

For breaking changes, include `BREAKING CHANGE:` in the footer of the commit message (major version bump).

### Manual Release Checklist

For manual verification before merging to main:

- [ ] All code changes are complete and tested
- [ ] All tests pass: `flutter test`
- [ ] Code analysis passes: `flutter analyze`
- [ ] Documentation is updated (README.md, code comments)
- [ ] Example app works with the new features

## Publishing to pub.dev

The automated publishing to pub.dev is currently disabled. To publish manually after a release:

```
flutter pub publish
```

In the future, to enable automated publishing:

1. Generate pub.dev credentials and add them as a GitHub secret named `PUB_CREDENTIALS`
2. Uncomment the `PUB_CREDENTIALS` environment variable in the `.github/workflows/release.yml` file

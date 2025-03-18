# ZeatMap Development Guidelines

## Project Overview
ZeatMap is a Flutter package for creating highly customizable heatmaps with support for date-based visualization and interactive features. The package provides flexible layouts, date navigation, and customizable appearances.

## Commands
- Run all tests: `flutter test`
- Run a specific test: `flutter test test/zeatmap_test.dart -p "ZeatMapItem"` 
- Check analysis issues: `flutter analyze`
- Format code: `flutter format lib test example`
- Update package dependencies: `flutter pub get`
- Build example app: `cd example/demo && flutter run`
- Generate documentation: `dart doc .`

## Code Style Guidelines
- **Imports**: Group imports by Flutter, external packages, then local imports
- **Naming**: Use camelCase for variables/functions, PascalCase for classes
- **Types**: Use explicit types for public APIs, generics when appropriate
- **Documentation**: Document all public APIs with clear examples
- **Widget Structure**: Follow the standard Flutter widget composition pattern
- **Error Handling**: Use asserts for developer errors, try/catch for runtime errors
- **Parameters**: Required parameters first, then optional named parameters
- **Formatting**: Keep line length under 80 characters
- **Testing**: Write unit tests for all business logic and widget tests for UI components

## Architecture
- Keep widget code in `lib/src/` directory
- Expose public API through main barrel file `lib/zeatmap.dart`
- Follow single responsibility principle for all classes
- Use composition over inheritance when appropriate
- Keep UI components separate from business logic
- Core components:
  - `ZeatMap`: Main widget component
  - `ZeatMapItem`: Individual cell representation
  - `ZeatMapPosition`: Grid position handler
  - `ZeatMapLegendItem`: Legend representation

## Documentation Standards
- Use /// for public API documentation
- Include code examples in documentation for complex widgets or functions
- Document all parameters and return types
- Add usage notes for non-obvious behaviors
- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart/documentation) documentation guidelines

## Pull Request Process
1. Ensure code passes all tests: `flutter test`
2. Verify there are no analysis issues: `flutter analyze`
3. Format code properly: `flutter format lib test example`
4. Update documentation if needed
5. Update CHANGELOG.md with changes
6. Request review from at least one team member

## Version Control Practices
- Use feature branches for development
- Follow [Conventional Commits](https://www.conventionalcommits.org/) format for all commits
  - `feat`: New feature (minor version bump)
  - `fix`: Bug fix (patch version bump)
  - `docs`: Documentation changes (no version bump)
  - `chore`: Routine tasks (no version bump)
  - `refactor`: Code changes that neither fix a bug nor add a feature (no version bump)
  - Include `BREAKING CHANGE:` in the footer for major version bumps
- Keep commits focused on single responsibilities
- Rebase feature branches on main before merging

## Package Publishing & Semantic Versioning
- The package uses automated semantic versioning with [semantic-release-pub](https://github.com/zeshuaro/semantic-release-pub)
- Version numbers are automatically determined based on commit messages
- GitHub Actions workflow automatically:
  - Analyzes commit messages to determine version number
  - Updates version in pubspec.yaml
  - Updates CHANGELOG.md
  - Creates a Git tag and GitHub release
- For manual verification before merging to main:
  - Run final tests and analysis before publishing
  - Use `flutter pub publish --dry-run` to validate package
- When ready to publish to pub.dev:
  - Generate pub.dev credentials and add as GitHub secret `PUB_CREDENTIALS`
  - Uncomment `PUB_CREDENTIALS` line in `.github/workflows/release.yml`

## Performance Considerations
- Optimize rendering for large datasets
- Use const constructors where appropriate
- Implement proper widget rebuilding strategies
- Cache expensive computations
- Test with large date ranges to ensure smooth scrolling
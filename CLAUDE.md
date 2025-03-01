# ZeatMap Development Guidelines

## Commands
- Run all tests: `flutter test`
- Run a specific test: `flutter test test/zeatmap_test.dart -p "ZeatMapItem"` 
- Check analysis issues: `flutter analyze`
- Format code: `flutter format lib test example`

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
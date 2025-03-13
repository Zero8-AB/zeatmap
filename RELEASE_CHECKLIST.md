# Release Checklist for ZeatMap v0.2.0

## Pre-release Checks
- [ ] All code changes are complete and tested
- [ ] Documentation is updated (README.md, code comments)
- [ ] CHANGELOG.md is updated with all changes
- [ ] Version number is updated in pubspec.yaml (0.2.0)
- [ ] Example app works with the new features

## Release Process
1. Commit all changes with the message from release_message.txt:
   ```
   git add .
   git commit -m "Release v0.2.0: Add separate controls for drag-to-scroll and normal scrolling"
   ```

2. Create a git tag for the release:
   ```
   git tag -a v0.2.0 -m "Version 0.2.0"
   ```

3. Push changes and tags:
   ```
   git push origin main
   git push origin --tags
   ```

4. Publish to pub.dev (if applicable):
   ```
   flutter pub publish
   ```

## Post-release
- [ ] Verify the package is available on pub.dev
- [ ] Create a GitHub release with release notes
- [ ] Announce the release to users/stakeholders
- [ ] Start planning for the next release

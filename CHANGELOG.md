# Changelog

All notable changes to this GitHub Action will be documented in this file.

## v1.2 - 2022-06-16

Adding new parameters to action

### Added
- doc: CHANGELOG.md to keep track of changes
- new: `protect-files` allows to keep file from old deployment during new deployment. Useful when files are not tracked by git.

## v1.1 - 2022-06-06

Adding new parameters to action

### Added 
- new: `pre-command` allows to write command script to run **before deployment phase** (_ie. docker-compose down_).
- new: `post-command` allows to write command script to run **after deployment phase within the 'target-directory'** (_ie. docker-compose up_).

## v1 - 2022-06-03

SSH deployment method has changed

### Added
- new: entrypoint.sh updated. Docs added and code readability improved
- new: env have changed to simplify deployment. Same for deploy
- doc: README.md updated to changes

### Changed
- ref: works on SSH-support server
- ref: log each steps 

### Fixed
- fix: action.yml is updated and follow GitHub action guideline
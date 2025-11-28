# CloudNorth Git Workflow Strategy

## Branch Structure
- main - Production-ready code
- develop - Integration branch for features
- feature/* - New features
- hotfix/* - Critical fixes

## Development Workflow
1. git checkout develop
2. git checkout -b feature/your-feature
3. Make changes and commit
4. git push origin feature/your-feature
5. Create Pull Request to develop

## Commit Message Types
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance

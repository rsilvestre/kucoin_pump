# Code Quality Guidelines

This document outlines the code quality standards and practices for the KucoinPump project.

## Code Formatting

All Elixir code should be formatted using the standard Elixir formatter:

```bash
make format  # Using Docker
# OR
mix format   # Using local Elixir
```

## Code Quality Tools

### Credo

Credo is used to enforce code quality standards. It can be run in different modes:

```bash
# Basic check
make credo

# Strict check (recommended before commits)
make credo-strict

# Attempt to fix common issues automatically
make credo-fix
```

### Dialyzer

Dialyzer performs type checking and can detect type inconsistencies:

```bash
make dialyzer
```

## Common Code Quality Issues

### Readability

- Use descriptive variable and function names
- Keep functions small and focused on a single responsibility
- Add comments for complex logic, but prefer clear code that doesn't need comments
- Use docstrings for public functions
- Follow consistent naming patterns

### Performance

- Avoid unnecessary database calls
- Be mindful of memory usage when working with large data structures
- Leverage Elixir/OTP's concurrency features appropriately

### Maintainability

- Write comprehensive tests for all modules
- Keep modules focused on a single responsibility
- Follow the project's domain organization (models, storage, application, helpers)
- Use appropriate abstractions and avoid code duplication

## Pre-Commit Workflow

Before committing changes, run the following commands:

1. `make format` - Format your code
2. `make credo-strict` - Check for code quality issues
3. `make dialyzer` - Check for type-related issues
4. `make test` - Ensure all tests pass

## CI Integration

The project uses GitHub Actions for continuous integration, which runs the same checks on pull requests.
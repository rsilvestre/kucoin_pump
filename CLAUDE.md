# KUCOIN PUMP - DEVELOPMENT GUIDE

## Build & Run Commands
- `mix deps.get` - Install dependencies
- `mix compile` - Compile project
- `mix test` - Run all tests
- `mix test path/to/test_file.exs` - Run specific test file
- `mix test path/to/test_file.exs:line_number` - Run specific test case
- `mix format` - Format code
- `mix dialyzer` - Run type checking (may take time on first run)
- `mix credo` - Run code quality analysis
- `mix credo --strict` - Run strict code quality checks
- `iex -S mix` - Start application with interactive REPL

## Code Style Guidelines
- Use snake_case for variables/functions, PascalCase for modules
- Leverage TypeCheck module for typing (@type!, @spec!)
- Write comprehensive guard clauses for function definitions
- Use docstrings with examples for documentation
- Organize code by domain (application, helpers, models, storage)
- Follow standard Elixir formatting conventions
- Handle errors through pattern matching and case statements
- Prefer pipelines (|>) for data transformation
- Use structs with @enforce_keys for required fields
- Write unit tests with ExUnit (test coverage encouraged)
- Use Ecto for all database operations
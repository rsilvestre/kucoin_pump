# KucoinPump

A real-time KuCoin exchange pump detector that monitors trading activity to identify potential price pumps or dumps.

![Screenshot](kucoinPumpterminal.png)

## What is this?

This application:
- Creates a KuCoin WebSocket connection to listen for real-time trades
- Aggregates information and groups trade data by price, ticks, and volume
- Displays the most actively traded, price-changed, and volume-changed symbols at regular intervals
- Detects anomalies that could indicate potential pumps or dumps
- Can send notifications to a Telegram bot (optional, disabled by default)

Based on the project by [ogu83](https://github.com/ogu83): [binancePump](https://github.com/ogu83/binancePump)

## Getting Started

### Option 1: Run with Docker Compose (Recommended)

This is the easiest way to get started with minimal setup.

1. Clone the repository:
   ```shell
   git clone https://github.com/rsilvestre/kucoin_pump.git
   cd kucoin_pump
   ```

2. Configure Environment Variables:
   - Copy the example environment file: `cp .env_example .env`
   - Edit the `.env` file with your configuration:
     ```
     # Telegram (Optional)
     TELEGRAM_ENABLED=false                   # Set to true to enable Telegram notifications
     TELEGRAM_BOT_TOKEN=your_telegram_bot_token
     TELEGRAM_CHAT_ID=your_telegram_chat_id
     
     # PostgreSQL Configuration
     PGDATABASE=kucoin_pump_repo
     PGUSER=postgres
     PGPASSWORD=postgres
     PGHOST=localhost
     PGPORT=5432
     ```
   - See the [Telegram Notifications](#telegram-notifications) section below for instructions on creating a bot and obtaining these values.

3. Start the application:
   ```shell
   docker-compose up -d
   ```

4. View logs:
   ```shell
   docker-compose logs -f
   ```

5. Stop the application:
   ```shell
   docker-compose down
   ```

### Option 2: Run Locally with Elixir

1. Clone the repository:
   ```shell
   git clone https://github.com/rsilvestre/kucoin_pump.git
   cd kucoin_pump
   ```

2. Install Elixir:
   - Follow the official installation guide: [https://elixir-lang.org/install.html](https://elixir-lang.org/install.html)

3. Install Hex package manager:
   ```shell
   mix local.hex
   ```

4. Install dependencies:
   ```shell
   mix deps.get
   ```

5. Compile the project:
   ```shell
   mix compile
   ```

6. Configure the application:
   - Copy the example configuration: `cp config/secrets_example.exs config/secrets.exs`
   - Edit `config/secrets.exs` with your configuration:
     ```elixir
     config :kucoin_pump,
       telegram_enabled: false,  # set to true to enable Telegram notifications
       telegram_bot_token: "your_token_here",
       telegram_chat_id: -123456789
     
     config :kucoin_pump, KucoinPump.Repo,
       database: "kucoin_pump_repo",
       username: "postgres",
       password: "postgres",
       hostname: "localhost",
       port: 5432,
       log: false
     ```
   - Alternatively, you can use environment variables by creating and sourcing an `.env` file:
     ```shell
     cp .env_example .env
     # Edit the .env file with your configuration
     source .env
     ```
   - See the [Telegram Notifications](#telegram-notifications) section below for instructions on creating a bot and obtaining these values

7. Run the application:
   ```shell
   iex -S mix
   ```

## Development

### Key Commands

#### Using Docker (Recommended)

A Makefile is provided for easy development with Docker:

- `make deps` - Install dependencies
- `make compile` - Compile project
- `make test` - Run all tests
- `make format` - Format code
- `make dialyzer` - Run type checking
- `make credo` - Run code quality analysis
- `make credo-strict` - Run strict code quality checks
- `make credo-fix` - Attempt to automatically fix common code quality issues
- `make run-dev` - Start application with interactive REPL in development mode
- `make run-prod` - Start application in production mode
- `make clean` - Clean up the Docker environment

#### Native Elixir

If you prefer to run commands directly with Elixir installed locally:

- `mix deps.get` - Install dependencies
- `mix compile` - Compile project
- `mix test` - Run all tests
- `mix format` - Format code
- `mix dialyzer` - Run type checking
- `mix credo` - Run code quality analysis
- `mix credo --strict` - Run strict code quality checks
- `iex -S mix` - Start application with interactive REPL

### Project Structure

- `lib/application` - Core application logic
- `lib/models` - Data structures and schemas
- `lib/storage` - Data persistence utilities
- `lib/helpers` - Utility functions
- `lib/kucoin_pump` - KuCoin-specific functionality
- `priv/repo/migrations` - Database migrations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

Please read our [Code Quality Guidelines](CODE_QUALITY.md) before contributing.

## Telegram Notifications

### Overview

This application supports sending notifications to Telegram for price alerts. **Telegram notifications are disabled by default** for simplicity. You can enable them by following the steps below.

### Setting Up Telegram Bot

To enable and use the Telegram notification features:

1. **First, enable Telegram notifications**:
   - In your `.env` file (for Docker): set `TELEGRAM_ENABLED=true`
   - In your `config/secrets.exs` (for local setup): set `telegram_enabled: true`

2. **Create a Telegram Bot**:
   - Open Telegram and search for the "BotFather" (@BotFather)
   - Start a chat with BotFather and send the command `/newbot`
   - Follow the instructions to name your bot and choose a username (must end with "bot")
   - Once created, BotFather will give you a token that looks like `123456789:ABCdefGhIJKlmNoPQRsTUVwxyZ`
   - This is your `TELEGRAM_BOT_TOKEN`

3. **Get Your Chat ID**:
   - Option 1: Start a chat with your new bot, send a message, then visit:
     ```
     https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
     ```
     Look for the `"chat":{"id":number}` value in the response. This number is your chat ID.
   
   - Option 2: Add the bot "@userinfobot" to a group, then send a message in that group. The bot will reply with your user ID.
   
   - For a group chat, the chat ID will be a negative number (e.g., `-123456789`)

4. **Configure Your Application**:
   - Add these values to your `.env` file (for Docker) or `config/secrets.exs` (for local setup)
   - The telegram_bot_token should include the entire token
   - The telegram_chat_id should be entered as an integer (e.g., `-123456789`)

5. **Test Your Bot**:
   - After starting the application, your bot should become active
   - You can verify it's working by starting a chat with your bot or adding it to a group
   
### Disabling Telegram Notifications

If you want to disable Telegram notifications:
- Set `TELEGRAM_ENABLED=false` in your `.env` file (for Docker)
- Set `telegram_enabled: false` in your `config/secrets.exs` (for local setup)

This will prevent any messages from being sent to Telegram, even if the bot token and chat ID are configured.

## Environment Variables

The application can be configured using environment variables, which can be set in a `.env` file:

```
# Telegram Bot Configuration (Optional)
TELEGRAM_ENABLED=false                  # Set to true to enable Telegram notifications
TELEGRAM_BOT_TOKEN=xxxxxxxx:yyyyyyyyyy  # Your Telegram bot token
TELEGRAM_CHAT_ID=-zzzzzzzzz             # Your Telegram chat ID (often negative for groups)

# PostgreSQL Configuration
PGDATABASE=kucoin_pump_repo             # Database name
PGUSER=postgres                         # Database username
PGPASSWORD=postgres                     # Database password
PGHOST=localhost                        # Database host
PGPORT=5432                             # Database port
```

You can create this file by copying the provided example: `cp .env_example .env`

Note: These environment variables are automatically used by the Docker setup. For local development, they will be used if you source the .env file before running the application.

## License

This project is open source.

## Context Priming
Read README.md, CLAUDE.md, ai_docs/*, and run git ls-files to understand this codebase.


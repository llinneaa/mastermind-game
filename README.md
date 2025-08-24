# Mastermind Game

A modern **web-based implementation** of the classic Mastermind puzzle, built with **Ruby on Rails 8.0**. This application challenges players to crack a secret, computer-generated code within **10 attempts**. After each guess, the game provides feedback on how many digits are correct and how many are in the correct position, helping players apply logic and deduction to find the solution.  

The game supports both **single-player** and **collaborative** modes, with configurable difficulty levels:  

- **Single Player:** Play against the computer to solve its secret code.
- **Collaborative Mode:** Two players work together against the computer, taking turns to guess and sharing the win (or loss) as a team.  
- **Difficulty Levels:** Choose from three levels that vary the code length and number range, making the game accessible for beginners or challenging for advanced players.  

The application also **tracks detailed statistics**, allowing players to review performance across sessions:  
- Total games played and won  
- Win rates by mode and difficulty  
- Average guesses per win  
- Best victories (fewest attempts)  

## Key Highlights
- **Simple and intuitive web interface** for entering guesses and tracking progress  
- **Real-time feedback** after each guess  
- **Progressive difficulty levels** to keep gameplay engaging  
- **Collaborative mode** for team problem-solving  
- **Comprehensive stats tracking** for performance analysis  

## Design Philosophy

The implementation follows these key principles:
- **Separation of Concerns**: Game logic is isolated in models, keeping controllers thin
- **RESTful Architecture**: Standard Rails conventions for predictable API endpoints
- **Progressive Enhancement**: Basic functionality works without JavaScript
- **Test-Driven Development**: Comprehensive test coverage ensures reliability

## Prerequisites

- Ruby 3.2.2 or higher
- PostgreSQL 14+ 

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone [your-repo-url]
   cd mastermind-game
   ```

2. Install Ruby dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   # Create and configure config/database.yml with your PostgreSQL credentials
   cp config/database.yml.example config/database.yml
   
   # Create and migrate the database
   bin/rails db:create
   bin/rails db:migrate
   ```

4. Start the server:
   ```bash
   bin/rails server
   ```

5. Visit `http://localhost:3000` in your browser

## Playing the Game

1. Login:
   - Enter a username to start
   - No password required for demo purposes

2. Start a New Game:
   - Choose game mode (Single Player or Collaborative)
   - Select difficulty level
   - For collaborative mode, select a second player

3. Gameplay:
   - Try to guess the secret code
   - Each guess provides feedback:
     - Number of correct digits in correct positions
     - Number of correct digits in wrong positions
   - Maximum of 10 guesses per game
   - In collaborative mode, players take turns guessing

## Features

- Single Player Mode: Challenge the computer at your own pace
- Collaborative Mode: Team up with another player to crack the code together
- Multiple Difficulty Levels:
  - Easy: 4 digits (0-7)
  - Medium: 4 digits (0-9)
  - Hard: 5 digits (0-9)
- Comprehensive Statistics:
  - Individual performance tracking
  - Collaborative game statistics
  - Win rates by difficulty
  - Best scores tracking

## Code Structure

- `app/models/`:
  - `user.rb`: User model with stats calculation methods
  - `game.rb`: Game logic and state management
  - `guess.rb`: Guess processing and feedback generation

- `app/controllers/`:
  - `games_controller.rb`: Game creation and management
  - `guesses_controller.rb`: Guess processing and turn management
  - `users_controller.rb`: User management and stats

- `app/views/`:
  - Organized by controller with shared partials
  - Uses Rails' built-in view helpers
  - Responsive design

## Technical Decisions

1. **Random Number Generation**:
   - Uses Random.org API for true random number generation
   - Supports configurable number ranges for different difficulty levels

2. **Database Design**:
   - Normalized schema with separate tables for games and guesses
   - Efficient querying for statistics
   - Supports both single-player and collaborative modes

3. **Testing**:
   - Comprehensive test suite using Minitest
   - Fixtures for common test scenarios

## Running Tests

```bash
bin/rails test
```

Tests cover:
- Model validations and business logic
- User Controller actions and responses



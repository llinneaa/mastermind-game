class User < ApplicationRecord
	has_many :games
	has_many :guesses

    validates :username, presence: true, uniqueness: true

    def games_completed
        games.where(status: "completed").count
    end

    def win_rate(difficulty = nil)
        games_to_count = difficulty ? games.where(difficulty: difficulty) : games
        completed = games_to_count.where(status: "completed").count
        return "No games completed!" if completed == 0
        (games_to_count.where(won: true).count.to_f / completed * 100).round(2)
    end

    def average_guesses_for_wins(difficulty = nil)
        won_games = games.where(won: true)
        won_games = won_games.where(difficulty: difficulty) if difficulty
        return "No games won!" if won_games.count == 0
        
        total_guesses = won_games.joins(:guesses).group('games.id').count
        (total_guesses.values.sum.to_f / total_guesses.count).round(2)
    end

    def best_win(difficulty = nil)
        won_games = games.where(won: true)
        won_games = won_games.where(difficulty: difficulty) if difficulty
        return "No games won!" if won_games.count == 0
        
        game_guesses = won_games.joins(:guesses).group('games.id').count
        game_guesses.values.min
    end

    # Calculate the fewest guesses in a winning game
    def best_game_guesses
        min = games.where(status: 'won').map { |g| g.guesses.count }.min
        min || "No games won yet :("
    end
end

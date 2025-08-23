class User < ApplicationRecord
	has_many :games
	has_many :guesses

    validates :username, presence: true, uniqueness: true

    def games_played
        games.count
    end

    def win_rate
        return "No games played!" if games_played == 0
        (games.where(status: 'won').count.to_f / games_played * 100).round(2)
    end

    def average_guesses
        return "No games played!" if games_played == 0
        games.joins(:guesses).group('games.id').average('guesses.count')
    end

    # Calculate the fewest guesses in a winning game
    def best_game_guesses
        min = games.where(status: 'won').map { |g| g.guesses.count }.min
        min || "No games won yet :("
    end
end

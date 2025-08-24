class User < ApplicationRecord
    has_many :games
    has_many :games_as_player2, class_name: 'Game', foreign_key: 'player2_id'
    has_many :guesses

    validates :username, presence: true, uniqueness: true

    # Single player stats methods
    def single_player_games
        games.where(game_type: 'single_player')
    end

    def games_completed
        single_player_games.where(status: "completed").count
    end

    def win_rate(difficulty = nil)
        games_to_count = difficulty ? single_player_games.where(difficulty: difficulty) : single_player_games
        completed = games_to_count.where(status: "completed").count
        return "No games completed!" if completed == 0
        (games_to_count.where(won: true).count.to_f / completed * 100).round(2)
    end

    def average_guesses_for_wins(difficulty = nil)
        won_games = single_player_games.where(won: true)
        won_games = won_games.where(difficulty: difficulty) if difficulty
        return "No games won!" if won_games.count == 0
        
        total_guesses = won_games.joins(:guesses).group('games.id').count
        (total_guesses.values.sum.to_f / total_guesses.count).round(2)
    end

    def best_win(difficulty = nil)
        won_games = single_player_games.where(won: true)
        won_games = won_games.where(difficulty: difficulty) if difficulty
        return "No games won!" if won_games.count == 0
        
        game_guesses = won_games.joins(:guesses).group('games.id').count
        game_guesses.values.min
    end

    # Collaborative stats methods
    def collaborative_games_with(other_player)
        Game.where(game_type: 'collaborative')
            .where('(games.user_id = ? AND games.player2_id = ?) OR (games.user_id = ? AND games.player2_id = ?)',
                  id, other_player.id, other_player.id, id)
    end

    def collaborative_stats_with(other_player)
        games = collaborative_games_with(other_player)
        completed_games = games.where(status: 'completed')
        
        total_games = completed_games.count
        
        # Games won against the computer
        total_wins = completed_games.where(won: true).count
        
        # Get all games that were won
        winning_games = completed_games.where(won: true)
        
        # Find who made the winning moves by looking at the last guess of each game
        player1_wins = winning_games
                   .joins(:guesses)
                   .where(guesses: { user_id: id })
                   .where("guesses.id IN (SELECT MAX(guesses.id) FROM guesses WHERE guesses.game_id = games.id GROUP BY guesses.game_id)")
                   .count
                   
        player2_wins = winning_games
                      .joins(:guesses)
                      .where(guesses: { user_id: other_player.id })
                      .where("guesses.id IN (SELECT MAX(guesses.id) FROM guesses WHERE guesses.game_id = games.id GROUP BY guesses.game_id)")
                      .count
        
        computer_wins = total_games - total_wins

        # Determine who's the champion
        winners = []
        winners << username if player1_wins > 0
        winners << other_player.username if player2_wins > 0
        winners << "Computer" if computer_wins > 0

        # Find who has the most wins
        max_wins = [player1_wins, player2_wins, computer_wins].max

        if max_wins == 0
            champion = "No champion yet!"
        else
            # Who has the max wins?
            champions = []
            champions << username if player1_wins == max_wins
            champions << other_player.username if player2_wins == max_wins
            champions << "Computer" if computer_wins == max_wins

            champion = champions.length > 1 ? "Tied between #{champions.join(' and ')}!" : champions.first
        end

        {
            total_games: total_games,
            total_wins: total_wins,
            player1_wins: player1_wins,
            player2_wins: player2_wins,
            computer_wins: computer_wins,
            champion: champion,
            win_rate: total_games > 0 ? (total_wins.to_f / total_games * 100).round(1) : 0
        }
    end
end

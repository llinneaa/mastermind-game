require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:player_one)
    @player2 = users(:player_two)
  end

  # Helper methods for creating test data
  def create_single_player_game(user:, won: true, difficulty: "easy")
    secret_code = case difficulty
                 when "easy" then "1,2,3,4"    # 4 digits (0-7)
                 when "medium" then "5,8,0,1"  # 4 digits (0-9)
                 when "hard" then "5,8,0,1,9"  # 5 digits (0-9)
                 else "1,2,3,4"
                 end

    user.games.create!(
      secret_code: secret_code,
      game_type: "single_player",
      status: "completed",
      difficulty: difficulty,
      won: won
    )
  end

  def create_collaborative_game(player1:, player2:, won: true, winner: nil)
    game = player1.games.create!(
      secret_code: "1,2,3,4",
      game_type: "collaborative",
      status: "completed",
      player2: player2,
      won: won
    )
    
    if won && winner
      game.guesses.create!(input_code: "1,2,3,4", user: winner)
    end
    
    game
  end

  test "username validation" do
    # Must have a username
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"

    # Username must be unique
    duplicate_user = User.new(username: @user.username)
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:username], "has already been taken"
  end

  test "games_completed only counts single player games" do
    # Clean up any existing games
    @user.games.each { |game| game.guesses.destroy_all }
    @user.games.destroy_all
    
    # Create one single player and one collaborative game
    @user.games.create!(
      secret_code: "1,2,3,4",
      status: "completed",
      game_type: "single_player"
    )
    @user.games.create!(
      secret_code: "1,2,3,4",
      status: "completed",
      game_type: "collaborative",
      player2: @player2
    )

    assert_equal 1, @user.games_completed
  end

  test "win_rate calculation" do
    # Clean up any existing games
    @user.games.each { |game| game.guesses.destroy_all }
    @user.games.destroy_all
    
    # Create exactly one won and one lost game for clean win rate calculation
    create_single_player_game(user: @user, won: true)
    create_single_player_game(user: @user, won: false)

    assert_equal 50.0, @user.win_rate.round(1)  # 1 win, 1 loss = 50%
  end

  test "win_rate with no games" do
    @user.games.each { |game| game.guesses.destroy_all }
    @user.games.destroy_all
    assert_equal "No games completed!", @user.win_rate
  end

  test "win_rate by difficulty" do
    # Clean up any existing games
    @user.games.each { |game| game.guesses.destroy_all }
    @user.games.destroy_all
    
    # Create one winning game for each difficulty
    create_single_player_game(user: @user, difficulty: "easy", won: true)
    create_single_player_game(user: @user, difficulty: "medium", won: true)
    create_single_player_game(user: @user, difficulty: "hard", won: true)

    # And one losing game for each to test win rate
    create_single_player_game(user: @user, difficulty: "easy", won: false)
    create_single_player_game(user: @user, difficulty: "medium", won: false)
    create_single_player_game(user: @user, difficulty: "hard", won: false)

    # Each difficulty should show 50% win rate
    assert_equal 50.0, @user.win_rate("easy").round(1)
    assert_equal 50.0, @user.win_rate("medium").round(1)
    assert_equal 50.0, @user.win_rate("hard").round(1)
  end

  test "average_guesses_for_wins" do
    # Clean up existing games
    @user.games.each { |game| game.guesses.destroy_all }
    @user.games.destroy_all
    
    # Create two won games with known number of guesses
    game1 = create_single_player_game(user: @user, won: true)
    game2 = create_single_player_game(user: @user, won: true)
    
    # Create a lost game to ensure it's not counted
    lost_game = create_single_player_game(user: @user, won: false)
    
    # First game: 3 guesses
    2.times { game1.guesses.create!(input_code: "5,5,5,5", user: @user) }
    game1.guesses.create!(input_code: game1.secret_code, user: @user)
    
    # Second game: 5 guesses
    4.times { game2.guesses.create!(input_code: "5,5,5,5", user: @user) }
    game2.guesses.create!(input_code: game2.secret_code, user: @user)
    
    # Lost game: 4 guesses (shouldn't affect average)
    4.times { lost_game.guesses.create!(input_code: "5,5,5,5", user: @user) }

    assert_equal 4.0, @user.average_guesses_for_wins.round(1)  # (3 + 5) / 2 = 4.0
  end

  test "best_win finds game with fewest guesses" do
    # Clean up any existing games
    @user.games.each { |game| game.guesses.destroy_all }
    @user.games.destroy_all

    # Create two games with different numbers of guesses
    game1 = @user.games.create!(secret_code: "1,2,3,4", status: "completed", game_type: "single_player", won: true)
    game2 = @user.games.create!(secret_code: "1,2,3,4", status: "completed", game_type: "single_player", won: true)
    
    # First game: 3 guesses
    3.times do |i|
      input = i == 2 ? "1,2,3,4" : "5,5,5,5"
      game1.guesses.create!(input_code: input, user: @user)
    end
    
    # Second game: 5 guesses
    5.times do |i|
      input = i == 4 ? "1,2,3,4" : "5,5,5,5"
      game2.guesses.create!(input_code: input, user: @user)
    end

    assert_equal 3, @user.best_win
  end

  test "collaborative_games_with finds games between two players" do
    other_player = users(:other_player)  # Use fixture instead of creating new user
    
    # Clean up existing games
    [@user, @player2, other_player].each do |player|
      player.games.each { |game| game.guesses.destroy_all }
      player.games.destroy_all
    end
    
    # Create games in both directions
    game1 = create_collaborative_game(player1: @user, player2: @player2)
    game2 = create_collaborative_game(player1: @player2, player2: @user)
    other_game = create_collaborative_game(player1: @user, player2: other_player)

    games = @user.collaborative_games_with(@player2)
    assert_equal 2, games.count
    assert_includes games, game1
    assert_includes games, game2
    assert_not_includes games, other_game
  end

  test "collaborative_stats_with calculates correct stats" do
    # Clean up existing games
    @user.games.each { |game| game.guesses.destroy_all }
    @user.games.destroy_all
    @player2.games.each { |game| game.guesses.destroy_all }
    @player2.games.destroy_all

    # Create different collaborative game outcomes
    game1 = create_collaborative_game(player1: @user, player2: @player2, winner: @user)
    game2 = create_collaborative_game(player1: @user, player2: @player2, winner: @player2)
    game3 = create_collaborative_game(player1: @user, player2: @player2, won: false)
    
    stats = @user.collaborative_stats_with(@player2)
    assert_equal 3, stats[:total_games]
    assert_equal 2, stats[:total_wins]
    assert_equal 1, stats[:player1_wins]
    assert_equal 1, stats[:player2_wins]
    assert_equal 1, stats[:computer_wins]
    assert_equal 66.7, stats[:win_rate].round(1)
    assert_equal "Tied between test_user_1 and test_user_2 and Computer!", stats[:champion]
  end

  test "collaborative_stats_with handles no games" do
    # Clean up all games for both players
    [@user, @player2].each do |player|
      player.games.each { |game| game.guesses.destroy_all }
      player.games.destroy_all
    end
    
    stats = @user.collaborative_stats_with(@player2)
    assert_equal 0, stats[:total_games]
    assert_equal 0, stats[:total_wins]
    assert_equal "No champion yet!", stats[:champion]
    stats = @user.collaborative_stats_with(@player2)
    
    assert_equal 0, stats[:total_games]
    assert_equal 0, stats[:total_wins]
    assert_equal 0, stats[:player1_wins]
    assert_equal 0, stats[:player2_wins]
    assert_equal 0, stats[:computer_wins]
    assert_equal 0, stats[:win_rate]
    assert_equal "No champion yet!", stats[:champion]
  end
end

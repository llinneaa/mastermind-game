require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @user = users(:player_one)
    @player2 = users(:player_two)
  end

  test "validates required attributes" do
    game = Game.new
    refute game.valid?, "Expected game to be invalid without required attributes"
    
    # Test each field individually
    game = Game.new(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    
    # Test omitting each required field one at a time
    [:secret_code, :status, :difficulty, :hints_used, :max_hints, :game_type].each do |field|
      invalid_game = game.dup
      invalid_game.send("#{field}=", nil)
      refute invalid_game.valid?, "Expected game to be invalid without #{field}"
      assert_includes invalid_game.errors[field], "can't be blank"
    end
    
    # Test the game type inclusion validation
    invalid_game = game.dup
    invalid_game.game_type = "invalid_type"
    refute invalid_game.valid?
    assert_includes invalid_game.errors[:game_type], "is not included in the list"
    
    # Test that a valid game passes validation
    assert game.valid?, "Expected game to be valid with all required attributes"
  end

  test "game type must be valid" do
    game = Game.new(game_type: "invalid_type")
    assert_not game.valid?
    assert_includes game.errors[:game_type], "is not included in the list"
  end

  test "creates valid single player game" do
    game = Game.new(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    assert game.valid?
  end

  test "creates valid collaborative game" do
    game = Game.new(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "collaborative",
      user: @user,
      player2: @player2
    )
    assert game.valid?
  end

  test "collaborative? returns correct value" do
    single_player = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    assert_not single_player.collaborative?

    collaborative = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "collaborative",
      user: @user,
      player2: @player2
    )
    assert collaborative.collaborative?
  end

  test "current_players_turn? works correctly" do
    # Single player game - always current player's turn
    single_player = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    assert single_player.current_players_turn?(@user)

    # Collaborative game - depends on current_turn_user_id
    collab_game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "collaborative",
      user: @user,
      player2: @player2
    )
    
    assert collab_game.current_players_turn?(@user) # First player's turn by default
    collab_game.switch_turns
    assert collab_game.current_players_turn?(@player2)
  end

  test "switch_turns works correctly" do
    game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "collaborative",
      user: @user,
      player2: @player2
    )

    assert_equal @user.id, game.current_turn_user_id
    game.switch_turns
    assert_equal @player2.id, game.current_turn_user_id
    game.switch_turns
    assert_equal @user.id, game.current_turn_user_id
  end

  test "valid_guess_format? for different difficulties" do
    # Easy game (4 digits 0-7)
    easy_game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    assert easy_game.send(:valid_guess_format?, "1234")
    assert easy_game.send(:valid_guess_format?, "0000")
    assert easy_game.send(:valid_guess_format?, "7777")
    assert_not easy_game.send(:valid_guess_format?, "8888")
    assert_not easy_game.send(:valid_guess_format?, "123")
    assert_not easy_game.send(:valid_guess_format?, "12345")

    # Medium game (4 digits 0-9)
    medium_game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "medium",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    assert medium_game.send(:valid_guess_format?, "1234")
    assert medium_game.send(:valid_guess_format?, "9999")
    assert_not medium_game.send(:valid_guess_format?, "123")
    assert_not medium_game.send(:valid_guess_format?, "12345")

    # Hard game (5 digits 0-9)
    hard_game = Game.create!(
      secret_code: "1,2,3,4,5",
      status: "active",
      difficulty: "hard",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    assert hard_game.send(:valid_guess_format?, "12345")
    assert hard_game.send(:valid_guess_format?, "99999")
    assert_not hard_game.send(:valid_guess_format?, "1234")
    assert_not hard_game.send(:valid_guess_format?, "123456")
  end

  test "process_guess for completed game" do
    game = Game.create!(
      secret_code: "1,2,3,4",
      status: "completed",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    result = game.process_guess("1234")
    assert_equal "Game is already completed.", result[:error]
  end

  test "process_guess with maximum guesses" do
    game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    10.times do
      game.guesses.create!(input_code: "5555", user: @user)
    end
    
    result = game.process_guess("1234")
    assert_equal "Maximum number of guesses reached.", result[:error]
  end

  test "process_guess with invalid format" do
    game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    result = game.process_guess("12345")
    assert_includes result[:error], "Invalid guess format"
  end

  test "process_guess for winning guess" do
    game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    result = game.process_guess("1234")
    assert_equal "You won!", result[:message]
    assert_equal "completed", result[:status]
    assert game.won?
  end

  test "game is lost after 10 incorrect guesses" do
    game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    # Create 9 guesses directly
    9.times do
      game.guesses.create!(input_code: "5555", user: @user)
    end
    
    # Test the final guess
    result = game.process_guess("5555") # 10th and final guess
    assert_equal "You lost!", result[:message]
    assert_equal "completed", result[:status]
    assert_not game.won?
  end

  test "format_error_message for different difficulties" do
    easy_game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "easy",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    assert_includes easy_game.send(:format_error_message), "4 digits between 0 and 7"

    medium_game = Game.create!(
      secret_code: "1,2,3,4",
      status: "active",
      difficulty: "medium",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    assert_includes medium_game.send(:format_error_message), "4 digits between 0 and 9"

    hard_game = Game.create!(
      secret_code: "1,2,3,4,5",
      status: "active",
      difficulty: "hard",
      hints_used: 0,
      max_hints: 3,
      game_type: "single_player",
      user: @user
    )
    assert_includes hard_game.send(:format_error_message), "5 digits between 0 and 9"
  end
end

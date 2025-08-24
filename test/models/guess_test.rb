require "test_helper"

class GuessTest < ActiveSupport::TestCase
  def setup
    @user = users(:player_one)
    @game = @user.games.create!(
      secret_code: "1,2,3,4",
      status: "active",
      game_type: "single_player",
      difficulty: "easy"
    )
  end

  test "guess requires user and game" do
    guess = Guess.new(input_code: "1,2,3,4")
    assert_not guess.valid?
    assert_includes guess.errors.attribute_names, :user
    assert_includes guess.errors.attribute_names, :game
  end

  test "feedback calculation for exact match" do
    guess = @game.guesses.create!(
      input_code: "1,2,3,4",
      user: @user
    )
    guess.generate_feedback(@game.secret_code)
    
    assert_equal "4 correct numbers, 4 correct locations", guess.feedback
  end

  test "feedback calculation for no match" do
    guess = @game.guesses.create!(
      input_code: "5,5,5,5",
      user: @user
    )
    guess.generate_feedback(@game.secret_code)
    
    assert_equal "0 correct numbers, 0 correct locations", guess.feedback
  end

  test "feedback calculation for partial number and location matches" do
    guess = @game.guesses.create!(
      input_code: "1,2,5,6",
      user: @user
    )
    guess.generate_feedback(@game.secret_code)
    
    assert_equal "2 correct numbers, 2 correct locations", guess.feedback
  end

  test "feedback calculation with correct numbers in wrong locations" do
    guess = @game.guesses.create!(
      input_code: "4,3,2,1",
      user: @user
    )
    guess.generate_feedback(@game.secret_code)
    
    assert_equal "4 correct numbers, 0 correct locations", guess.feedback
  end

  test "feedback handles different formats of secret code and input" do
    # Test with comma-separated format
    guess1 = @game.guesses.create!(
      input_code: "1,2,3,4",
      user: @user
    )
    guess1.generate_feedback("1,2,3,4")
    assert_equal "4 correct numbers, 4 correct locations", guess1.feedback

    # Test with non-comma format
    guess2 = @game.guesses.create!(
      input_code: "1234",
      user: @user
    )
    guess2.generate_feedback("1234")
    assert_equal "4 correct numbers, 4 correct locations", guess2.feedback
  end

  test "feedback with repeating numbers" do
    game = @user.games.create!(
      secret_code: "1,1,2,2",
      status: "active",
      game_type: "single_player",
      difficulty: "easy"
    )

    # Test one matching pair
    guess1 = game.guesses.create!(
      input_code: "1,3,4,5",
      user: @user
    )
    guess1.generate_feedback(game.secret_code)
    assert_equal "1 correct number, 1 correct location", guess1.feedback

    # Test both pairs matching but in wrong positions
    guess2 = game.guesses.create!(
      input_code: "2,2,1,1",
      user: @user
    )
    guess2.generate_feedback(game.secret_code)
    assert_equal "4 correct numbers, 0 correct locations", guess2.feedback
  end

  test "feedback pluralization" do
    # Test singular number, singular location
    guess1 = @game.guesses.create!(
      input_code: "1,5,5,5",
      user: @user
    )
    guess1.generate_feedback(@game.secret_code)
    assert_equal "1 correct number, 1 correct location", guess1.feedback

    # Test plural numbers, singular location
    guess2 = @game.guesses.create!(
      input_code: "1,2,5,5",
      user: @user
    )
    guess2.generate_feedback(@game.secret_code)
    assert_equal "2 correct numbers, 2 correct locations", guess2.feedback
  end
end

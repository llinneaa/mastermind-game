class Game < ApplicationRecord
  belongs_to :user
  belongs_to :player2, class_name: 'User', optional: true
  has_many :guesses

  validates :secret_code, presence: true
  validates :status, presence: true
  validates :difficulty, presence: true
  validates :hints_used, presence: true
  validates :max_hints, presence: true
  validates :user_id, presence: true
  validates :game_type, presence: true, inclusion: { in: ['single_player', 'collaborative'] }
  
  before_create :set_initial_turn
  
  def collaborative?
    game_type == 'collaborative'
  end

  def current_players_turn?(user)
    return true unless collaborative?
    current_turn_user_id == user.id
  end

  def switch_turns
    return unless collaborative?
    next_player = current_turn_user_id == user_id ? player2_id : user_id
    update!(current_turn_user_id: next_player)
  end

  def process_guess(input_code)
    if status == "completed"
      return { error: "Game is already completed." }
    end

    if guesses.count >= 10
      return { error: "Maximum number of guesses reached." }
    end

    if !valid_guess_format?(input_code)
      return { error: format_error_message }
    end

    new_guess = Guess.create(
      input_code: input_code,
      game_id: self.id,
      user_id: collaborative? ? current_turn_user_id : user_id
    )

    new_guess.generate_feedback(secret_code)

    is_match = (input_code == secret_code.split(',').map(&:to_i).join)

    puts "\n\n\n\n input code: #{input_code}, secret code: #{secret_code.split(',').map(&:to_i).join}\n\n\n"

    if is_match
      self.update!(won: true, status: "completed")
      return {message: "You won!", status: "completed"}
    elsif guesses.count >= 10
      self.update!(status: "completed")
      return {feedback: new_guess.feedback, message: "You lost!", status: "completed"}
    else
      return {feedback: new_guess.feedback, status: "active"}
    end
  end

  private

  def set_initial_turn
    self.current_turn_user_id = user_id if collaborative?
  end

  def valid_guess_format?(input_code)
    # First check if it's the right length and only contains digits
    return false unless input_code.match?(/^\d{4,5}$/)
    
    # Then check if the digits are in the valid range for the difficulty
    digits = input_code.chars.map(&:to_i)
    
    case difficulty
    when 'hard'
      digits.length == 5 && digits.all? { |d| d >= 0 && d <= 9 }
    when 'medium'
      digits.length == 4 && digits.all? { |d| d >= 0 && d <= 9 }
    else # 'easy'
      digits.length == 4 && digits.all? { |d| d >= 0 && d <= 7 }
    end
  end

  def format_error_message
    case difficulty
    when 'hard'
      "Invalid guess format. Please enter exactly 5 digits between 0 and 9 (e.g. 12345)."
    when 'medium'
      "Invalid guess format. Please enter exactly 4 digits between 0 and 9 (e.g. 1234)."
    else # 'easy'
      "Invalid guess format. Please enter exactly 4 digits between 0 and 7 (e.g. 1234)."
    end
  end
end
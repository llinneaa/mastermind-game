class Game < ApplicationRecord
	belongs_to :user
	has_many :guesses

    validates :secret_code, presence: true
    validates :attempts_left, presence: true
    validates :status, presence: true
    validates :difficulty, presence: true
    validates :hints_used, presence: true
    validates :max_hints, presence: true
    validates :user_id, presence: true

  def self.valid_guess_format?(guess)
    guess =~ /^[0-7]{4}$/
  end

  def process_guess(user_guess, user_id)
    # Prevent more than 10 guesses
    return nil if guesses.count >= 10 || status == "completed"

    guess_record = guesses.create(guess: user_guess, user_id: user_id)
    feedback = guess_record.feedback_for(secret_code)

    won = (user_guess == secret_code)
    status = won || attempts_left <= 1 ? "completed" : "active"

    { guess_record: guess_record, feedback: feedback, status: status, won: won }
  end

  def decrement_attempts!
    self.attempts_left -= 1
    save!
  end
end

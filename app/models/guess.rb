class Guess < ApplicationRecord
  belongs_to :game
  belongs_to :user

  def feedback_for(secret_code)
    secret = secret_code.include?(',') ? secret_code.split(',').map(&:to_i) : secret_code.chars.map(&:to_i)
    guess = self.guess.include?(',') ? self.guess.split(',').map(&:to_i) : self.guess.chars.map(&:to_i)

    # Calculate number of correct locations
    correct_location = 0
    secret.each_with_index do |num, i|
      correct_location += 1 if num == guess[i]
    end

    secret_counts = Hash.new(0)
    guess_counts = Hash.new(0)

    # Count occurrences of each number in secret and guess
    secret.each do |num|
      secret_counts[num] += 1
    end

    guess.each do |num|
      guess_counts[num] += 1
    end

    # Calculate total correct numbers
    correct_numbers = 0
    secret_counts.keys.each do |num|
      correct_numbers += [secret_counts[num], guess_counts[num]].min
    end

    # Use the correct pluralization for numbers and locations
    number_word = correct_numbers == 1 ? "number" : "numbers"
    location_word = correct_location == 1 ? "location" : "locations"
    "#{correct_numbers} correct #{number_word}, #{correct_location} correct #{location_word}"
  end
end

class Guess < ApplicationRecord
  belongs_to :game
  belongs_to :user

  #validates :input_code, presence: true

  def generate_feedback(secret_code)
    self.update(feedback: feedback_for(secret_code))
  end


  def feedback_for(secret_code)
    secret = secret_code.include?(',') ? secret_code.split(',').map(&:to_i) : secret_code.chars.map(&:to_i)
    input_code = self.input_code.include?(',') ? self.input_code.split(',').map(&:to_i) : self.input_code.chars.map(&:to_i)

    # Calculate number of correct locations
    correct_location = 0
    secret.each_with_index do |num, i|
      correct_location += 1 if num == input_code[i]
    end

    secret_counts = Hash.new(0)
    input_code_counts = Hash.new(0)

    # Count occurrences of each number in secret and input_code
    secret.each do |num|
      secret_counts[num] += 1
    end

    input_code.each do |num|
      input_code_counts[num] += 1
    end

    # Calculate total correct numbers
    correct_numbers = 0
    secret_counts.keys.each do |num|
      correct_numbers += [secret_counts[num], input_code_counts[num]].min
    end

    # Use the correct pluralization for numbers and locations
    if correct_numbers == 1
      number_word = "number"
    else
      number_word = "numbers"
    end

    if correct_location == 1
      location_word = "location"
    else
      location_word = "locations"
    end

    "#{correct_numbers} correct #{number_word}, #{correct_location} correct #{location_word}"
  end
end

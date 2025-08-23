class GuessesController < ApplicationController
	def create
		@game = Game.find(params[:game_id])
		@user = User.find(session[:user_id])
		guess_value = params[:guess]

		# Evaluate guess, generate feedback
		feedback = evaluate_guess(@game.secret_code, guess_value)

		@guess = @game.guesses.create(
			guess: guess_value,
			feedback: feedback,
			user: @user
		)

		# Update attempts
		@game.attempts_left -= 1
		@game.save

		redirect_to game_path(@game)
	end

	private

	def evaluate_guess(secret_code, guess_value)
        # Convert strings to arrays of integers
		secret = secret_code.split(',').map(&:to_i)
		guess = guess_value.split(',').map(&:to_i)

        # Count correct locations
		correct_location = 0
		secret.each_with_index do |num, i|
		  correct_location += 1 if num == guess[i]
		end

		# Count total correct numbers
		secret_counts = Hash.new(0)
		guess_counts = Hash.new(0)

		secret.each do |num|
            secret_counts[num] += 1 
        end

		guess.each do |num|
            guess_counts[num] += 1 
        end

		correct_numbers = 0
		secret_counts.each_key do |num|
		  correct_numbers += [secret_counts[num], guess_counts[num]].min
		end

		# Return feedback to user
		"#{correct_numbers} correct numbers, #{correct_location} correct location"
	end
end

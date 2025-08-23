class GuessesController < ApplicationController
	def create
		@game = Game.find(params[:game_id])
		@user = User.find(session[:user_id])
		guess_value = params[:guess]

		@guess = @game.guesses.create(
			guess: guess_value,
			user: @user
		)

		# Generate feedback using Guess model method
		feedback = @guess.feedback_for(@game.secret_code)
		@guess.update(feedback: feedback)

		# Update attempts
		@game.decrement_attempts!

		redirect_to game_path(@game)
	end
end

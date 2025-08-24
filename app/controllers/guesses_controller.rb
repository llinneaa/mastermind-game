class GuessesController < ApplicationController
	def create
		@game = Game.find(params[:game_id])
		result = @game.process_guess(params[:guess])
		
		if result[:error]
			flash[:alert] = result[:error]
		elsif result[:message]
			flash[:notice] = result[:message]
		end
		redirect_to dashboard_path
	end
end

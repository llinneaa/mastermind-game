class GuessesController < ApplicationController
	def create
		@game = Game.find(params[:game_id])
		result = @game.process_guess(params[:guess])
		
		if result[:error]
			flash[:alert] = result[:error]
		elsif result[:message]
			flash[:notice] = result[:message]
		else
      # Only switch turns if it's a collaborative game and the game isn't over
      if @game.collaborative? && result[:status] != "completed"
        @game.switch_turns
      end
		end

		redirect_to dashboard_path
	end

  private

  def current_user
    @current_user ||= User.find(session[:user_id])
  end
end

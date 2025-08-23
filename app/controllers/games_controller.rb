class GamesController < ApplicationController
  before_action :set_game, only: [:show, :guess, :hint, :reset]

  def show
    # Renders the main game page
  end

  def create
    secret_code = fetch_secret_code
    @game = Game.create(
      secret_code: secret_code,
      attempts_left: 10,
      status: "active",
      difficulty: params[:difficulty] || "easy",
      hints_used: 0,
      max_hints: 3,
      user_id: params[:user_id]
    )
    # Check if the game was saved and id was created
    if @game.persisted?
        redirect_to dashboard_path
    else
        flash[:error] = "Game could not be created."
        redirect_to root_path
    end
  end

  def guess
    user_guess = params[:guess]

    unless Game.valid_guess_format?(user_guess)
      flash[:alert] = "Invalid guess format. Please enter exactly 4 digits between 0 and 7 (e.g. 1234)."
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('guess_form', partial: 'games/guess_form', locals: { game: @game }) }
        format.html { redirect_to game_path(@game) }
      end
      return
    end

    result = @game.process_guess(user_guess, session[:user_id])
    if result.nil?
      flash[:alert] = "No more guesses allowed. The game is over."
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('guess_form', partial: 'games/guess_form', locals: { game: @game }) }
        format.html { redirect_to game_path(@game) }
      end
      return
    end
    guess_record = result[:guess_record]
    feedback = result[:feedback]
    status = result[:status]
    won = result[:won]

    guess_record.update(feedback: feedback)

    if status == "completed"
      @game.update(status: status, won: won)
      flash[:success] = won ? "Congratulations! You won!" : "Game over! You've used all attempts."
    else
      @game.decrement_attempts!
    end
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to game_path(@game) }
    end
  end

  def hint
    # Provide a hint if available to user
    redirect_to game_path(@game)
  end

  def reset
    redirect_to game_path(@game)
  end

  def dashboard
    @user = User.find(session[:user_id])
    @game = @user.games.order(created_at: :desc).first
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def fetch_secret_code
    require 'net/http'
    require 'uri'
    # Fetch a secret code from an external API using parameters listed in instructions
    uri = URI('https://www.random.org/integers/?num=4&min=0&max=7&col=1&base=10&format=plain&rnd=new')
    response = Net::HTTP.get(uri)
    # Converts API response to a comma-separated string
    # String is more flexible than array of integers
    response.split.map(&:to_i).join(",")
  end
end

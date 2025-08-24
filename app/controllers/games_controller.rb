class GamesController < ApplicationController
  before_action :set_game, only: [:show, :hint, :reset]

  def show
    # Renders the main game page
  end

  def create
    # Check if user has any active games
    if Game.exists?(user_id: params[:user_id], status: "active")
      flash[:alert] = "Please complete your current game before starting a new one."
      redirect_to dashboard_path
      return
    end

    secret_code = fetch_secret_code
    @game = Game.create(
      secret_code: secret_code,
      status: "active",
      difficulty: params[:difficulty] || "easy",
      hints_used: 0,
      max_hints: 3,
      user_id: params[:user_id],
      game_type: params[:game_type] || "single_player",
      player2_id: params[:player2_id]
    )
    # Check if the game was saved and id was created
    if @game.persisted?
        redirect_to dashboard_path
    else
        flash[:error] = "Game could not be created."
        redirect_to root_path
    end
  end

  # def guess
  #   @game = Game.find(params[:id])
  #   user_guess = params[:guess]
  #   result = @game.process_guess(user_guess)
    
  #   if result[:error]
  #     flash[:alert] = result[:error]
  #   elsif result[:message]
  #     flash[:notice] = result[:message]
  #   end
    
  #   redirect_to dashboard_path  # Redirect back to dashboard instead of game path
  # end


  def hint
    # Provide a hint if available to user
    redirect_to game_path(@game)
  end

  def reset
    redirect_to game_path(@game)
  end

  def dashboard
    @user = User.find(session[:user_id])
    # Get the most recent game, regardless of status
    @game = @user.games.order(created_at: :desc).first
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def fetch_secret_code
    require 'net/http'
    require 'uri'

    # Set parameters based on difficulty
    case params[:difficulty]
    when 'hard'
      num = 5  # 5 digits
      max = 9  # 0-9
    when 'medium'
      num = 4  # 4 digits
      max = 9  # 0-9
    else # 'easy'
      num = 4  # 4 digits
      max = 7  # 0-7
    end

    # Fetch secret code from random.org
    uri = URI("https://www.random.org/integers/?num=#{num}&min=0&max=#{max}&col=1&base=10&format=plain&rnd=new")
    response = Net::HTTP.get(uri)
    # Converts API response to a comma-separated string
    response.split.map(&:to_i).join(",")
  end
end

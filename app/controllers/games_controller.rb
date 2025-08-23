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
    redirect_to game_path(@game)
  end

  def guess
    # Process guess, update attempts, and feedback
    redirect_to game_path(@game)
  end

  def hint
    # Provide a hint if available to user
    redirect_to game_path(@game)
  end

  def reset
    redirect_to game_path(@game)
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

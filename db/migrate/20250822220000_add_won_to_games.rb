class AddWonToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :won, :boolean, default: false, null: false
  end
end

class RemoveAttemptsLeftFromGames < ActiveRecord::Migration[8.0]
  def change
    remove_column :games, :attempts_left, :integer
  end
end

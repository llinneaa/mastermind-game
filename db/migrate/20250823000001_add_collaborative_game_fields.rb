class AddCollaborativeGameFields < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :game_type, :string, default: 'single_player'
    add_column :games, :player2_id, :integer
    add_column :games, :current_turn_user_id, :integer
    add_reference :guesses, :player, foreign_key: { to_table: :users }
  end
end

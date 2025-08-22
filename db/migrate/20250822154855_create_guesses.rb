class CreateGuesses < ActiveRecord::Migration[8.0]
  def change
    create_table :guesses do |t|
      t.string :guess
      t.string :feedback
      t.references :game, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end

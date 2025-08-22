class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :secret_code
      t.integer :attempts_left, default: 10
      t.string :status, default: "active"
      t.string :difficulty, default: "easy"
      t.integer :hints_used, default: 0
      t.integer :max_hints, default: 3
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end

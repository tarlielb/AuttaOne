class CreateKanbanColumns < ActiveRecord::Migration[7.1]
  def change
    create_table :kanban_columns do |t|
      t.string :name
      t.string :color
      t.integer :position
      t.references :kanban_board, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateKanbanBoards < ActiveRecord::Migration[7.1]
  def change
    create_table :kanban_boards do |t|
      t.string :name
      t.string :description
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end

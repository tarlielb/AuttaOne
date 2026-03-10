class AddKanbanFieldsToConversations < ActiveRecord::Migration[7.1]
  def change
    add_reference :conversations, :kanban_column, foreign_key: true
    add_column :conversations, :deal_value, :decimal, precision: 15, scale: 2, default: 0.0
  end
end

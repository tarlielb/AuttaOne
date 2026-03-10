class KanbanBoard < ApplicationRecord
  belongs_to :account
  has_many :kanban_columns, dependent: :destroy
end

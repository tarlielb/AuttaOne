class KanbanColumn < ApplicationRecord
  belongs_to :kanban_board
  has_many :conversations, dependent: :nullify
end

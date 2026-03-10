FactoryBot.define do
  factory :kanban_column do
    name { "MyString" }
    color { "MyString" }
    position { 1 }
    kanban_board { nil }
  end
end

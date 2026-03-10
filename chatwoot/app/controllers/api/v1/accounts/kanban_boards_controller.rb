class Api::V1::Accounts::KanbanBoardsController < Api::V1::Accounts::BaseController
  before_action :set_kanban_board, only: [:show, :update, :destroy]

  def index
    @kanban_boards = Current.account.kanban_boards.includes(:kanban_columns)
    render json: @kanban_boards.as_json(include: :kanban_columns)
  end

  def show
    render json: @kanban_board.as_json(include: :kanban_columns)
  end

  def create
    @kanban_board = Current.account.kanban_boards.new(kanban_board_params)
    if @kanban_board.save
      render json: @kanban_board.as_json(include: :kanban_columns), status: :created
    else
      render json: { errors: @kanban_board.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @kanban_board.update(kanban_board_params)
      render json: @kanban_board.as_json(include: :kanban_columns)
    else
      render json: { errors: @kanban_board.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @kanban_board.destroy
    head :no_content
  end

  private

  def set_kanban_board
    @kanban_board = Current.account.kanban_boards.find(params[:id])
  end

  def kanban_board_params
    params.require(:kanban_board).permit(:name, :description)
  end
end

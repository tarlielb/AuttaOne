import ApiClient from './ApiClient';

class KanbanAPI extends ApiClient {
  constructor() {
    super('kanban_boards', { accountScoped: true });
  }

  getColumns(boardId) {
    return this.axios.get(`/api/v1/accounts/${this.accountId}/kanban_boards/${boardId}/kanban_columns`);
  }

  updateColumn(boardId, columnId, data) {
    return this.axios.patch(`/api/v1/accounts/${this.accountId}/kanban_boards/${boardId}/kanban_columns/${columnId}`, data);
  }

  createColumn(boardId, data) {
    return this.axios.post(`/api/v1/accounts/${this.accountId}/kanban_boards/${boardId}/kanban_columns`, data);
  }

  deleteColumn(boardId, columnId) {
    return this.axios.delete(`/api/v1/accounts/${this.accountId}/kanban_boards/${boardId}/kanban_columns/${columnId}`);
  }
}

export default new KanbanAPI();

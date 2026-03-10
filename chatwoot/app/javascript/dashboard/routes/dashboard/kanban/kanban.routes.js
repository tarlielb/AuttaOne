import KanbanBoard from './Index.vue';
import { frontendURL } from '../../../helper/URLHelper';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/kanban'),
      name: 'kanban_board',
      roles: ['administrator', 'agent'],
      component: KanbanBoard,
    },
  ],
};

<template>
  <div class="h-full w-full bg-n-background flex flex-col pt-5 px-5 overflow-hidden">
    <div class="flex justify-between items-center mb-4">
      <h1 class="text-2xl font-bold text-n-slate-12">CRM Kanban</h1>
      <button @click="createColumn" class="bg-n-brand text-white px-4 py-2 rounded-md font-medium hover:bg-n-brand-dark transition-colors">
        + Adicionar Etapa
      </button>
    </div>
    
    <div class="flex-1 flex overflow-x-auto gap-4 items-start pb-4">
      <div v-if="loading" class="text-n-slate-11 w-full text-center mt-10">Carregando negociações...</div>
      <div v-else-if="!columns.length" class="text-n-slate-11 w-full text-center mt-10">Nenhuma etapa encontrada. Crie uma para começar!</div>
      
      <div 
        v-for="column in columns" 
        :key="column.id"
        class="bg-n-solid-2 w-80 rounded-lg p-3 shrink-0 flex flex-col h-full border border-n-weak"
      >
        <div class="flex justify-between items-center mb-4">
          <h3 class="font-semibold text-n-slate-12" :style="{ color: column.color }">
            {{ column.name }}
          </h3>
          <span class="text-xs font-semibold bg-n-alpha-2 text-n-slate-11 px-2 py-1 rounded-full">
            {{ formatCurrency(getColumnTotal(column.id)) }}
          </span>
        </div>
        
        <draggable
          v-model="columnsMap[column.id]"
          item-key="id"
          group="kanban"
          @change="onDragChange($event, column.id)"
          class="flex-1 bg-n-alpha-1 rounded-md p-2 space-y-2 overflow-y-auto"
        >
          <template #item="{ element }">
            <div 
              @click="openConversation(element.id)"
              class="bg-n-background shadow-sm border border-n-weak rounded p-3 cursor-pointer hover:border-n-brand transition-colors"
            >
              <div class="font-medium text-sm text-n-slate-12 mb-1">
                {{ element.meta?.sender?.name || 'Cliente Desconhecido' }}
              </div>
              <div class="text-xs text-n-slate-11">
                Negócio: {{ formatCurrency(element.deal_value || 0) }}
              </div>
            </div>
          </template>
        </draggable>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import { useStore } from 'vuex';
import draggable from 'vuedraggable';
import KanbanAPI from '../../api/kanban';
import ConversaAPI from '../../api/conversations';

const router = useRouter();
const store = useStore();
const loading = ref(true);
const board = ref(null);
const columns = ref([]);
const columnsMap = ref({}); // Maps column_id to array of conversations

const currentAccountId = computed(() => store.getters.getCurrentAccountId);

onMounted(async () => {
  await fetchBoardData();
});

const formatCurrency = (value) => {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value || 0);
};

const getColumnTotal = (columnId) => {
  const cards = columnsMap.value[columnId] || [];
  return cards.reduce((sum, card) => sum + Number(card.deal_value || 0), 0);
};

const openConversation = (id) => {
  router.push(`/app/accounts/${currentAccountId.value}/conversations/${id}`);
};

const createColumn = async () => {
  const name = prompt('Nome da nova etapa do Kanban:');
  if (!name) return;
  const color = prompt('Cor em HEX (Ex: #157eb7):', '#157eb7');
  
  try {
    const res = await KanbanAPI.createColumn(board.value.id, { name, color, position: columns.value.length + 1 });
    columns.value.push(res.data);
    columnsMap.value[res.data.id] = [];
  } catch (err) {
    alert('Erro ao criar a etapa!');
  }
};

const onDragChange = async (event, newColumnId) => {
  if (event.added) {
    const conversation = event.added.element;
    try {
      // Update kanban_column_id for conversation
      await ConversaAPI.update(conversation.id, { kanban_column_id: newColumnId });
    } catch (e) {
      console.error('Falha ao mover conversa', e);
    }
  }
};

const generateDefaultBoardAndColumns = async () => {
  const res = await KanbanAPI.create({ name: 'CRM Pipeline', description: 'Funil Principal' });
  const bData = res.data;
  const colNames = [
    { name: 'Novo Lead', color: '#16ebf9' },
    { name: 'Contato Feito', color: '#157eb7' },
    { name: 'Conversa em Andamento', color: '#5b2dff' },
    { name: 'Reunião Agendada', color: '#18b2ee' },
    { name: 'Proposta Enviada', color: '#bcff00' },
    { name: 'Ganho', color: '#00cc66' },
    { name: 'Perdido', color: '#ff7a00' }
  ];
  
  const createdCols = [];
  for (let i = 0; i < colNames.length; i++) {
    const cRes = await KanbanAPI.createColumn(bData.id, { ...colNames[i], position: i + 1 });
    createdCols.push(cRes.data);
  }
  return { board: bData, columns: createdCols };
};

const fetchBoardData = async () => {
  try {
    loading.value = true;
    let bData = null;
    let cols = [];
    
    // Fetch Kanban boards
    const boardRes = await KanbanAPI.get();
    if (boardRes.data.length === 0) {
      // Board doesn't exist, create it with defaults
      const generated = await generateDefaultBoardAndColumns();
      bData = generated.board;
      cols = generated.columns;
    } else {
      bData = boardRes.data[0];
      cols = bData.kanban_columns || [];
    }
    
    board.value = bData;
    columns.value = cols;
    
    // Init columns Map
    cols.forEach(c => { columnsMap.value[c.id] = []; });
    
    // Fetch all conversations for CRM mapping
    const convRes = await ConversaAPI.get({ status: 'all', sort_by: 'latest' });
    const allConversations = convRes.data?.data?.payload || [];
    
    allConversations.forEach(conv => {
      if (conv.kanban_column_id && columnsMap.value[conv.kanban_column_id]) {
        columnsMap.value[conv.kanban_column_id].push(conv);
      } else if (cols.length > 0) {
        // Fallback to first column if no column assigned
        columnsMap.value[cols[0].id].push(conv);
      }
    });

  } catch (error) {
    console.error('Failed to load CRM data', error);
  } finally {
    loading.value = false;
  }
};
</script>

import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('electronAPI', {
  // Projects
  listProjects: () => ipcRenderer.invoke('project:list'),
  getProject: (id: string) => ipcRenderer.invoke('project:get', id),
  createProject: (data: unknown) => ipcRenderer.invoke('project:create', data),
  updateProject: (id: string, updates: unknown) => ipcRenderer.invoke('project:update', id, updates),
  deleteProject: (id: string) => ipcRenderer.invoke('project:delete', id),
  selectFolder: () => ipcRenderer.invoke('project:selectFolder'),

  // Progress
  getProgress: (projectId: string) => ipcRenderer.invoke('progress:get', projectId),
  getGanttData: (projectId: string) => ipcRenderer.invoke('progress:getHistory', projectId),
  setManualProgress: (projectId: string, phaseId: string, pageCount: number) =>
    ipcRenderer.invoke('progress:manualSet', projectId, phaseId, pageCount),

  onProgressUpdated: (callback: (data: { projectId: string }) => void) => {
    ipcRenderer.removeAllListeners('progress:updated');
    ipcRenderer.on('progress:updated', (_event, data) => callback(data));
    return () => ipcRenderer.removeAllListeners('progress:updated');
  },

  // Work Mate
  getWorkMateSummary: (projectId: string) => ipcRenderer.invoke('workmate:getSummary', projectId),
  isWorkMateAvailable: () => ipcRenderer.invoke('workmate:isAvailable'),

  // AI Analysis
  analyzeProject: (projectId: string) => ipcRenderer.invoke('ai:analyze', projectId),

  // Settings
  getSettings: () => ipcRenderer.invoke('settings:get'),
  saveSettings: (settings: unknown) => ipcRenderer.invoke('settings:save', settings),
});

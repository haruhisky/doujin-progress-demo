import { app, BrowserWindow, ipcMain, dialog } from 'electron';
import * as path from 'path';
import { globalEventBus } from '../core/event-bus';
import { ModuleManager } from '../core/module-manager';
import { ProjectManager } from '../modules/project-manager/index';
import { FolderWatcher } from '../modules/folder-watcher/index';
import { WorkMateReader } from '../modules/workmate-reader/index';
import { AIAnalyzer } from '../modules/ai-analyzer/index';
import { TrayManager } from './tray';

let mainWindow: BrowserWindow | null = null;
let moduleManager: ModuleManager;
let trayManager: TrayManager;
let isQuitting = false;

function createWindow(): void {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 900,
    minHeight: 600,
    title: '同人誌進捗管理',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  mainWindow.loadFile(path.join(__dirname, '../renderer/index.html'));

  mainWindow.on('close', (e) => {
    if (!isQuitting) {
      e.preventDefault();
      mainWindow?.hide();
    }
  });
}

function getProjectManager(): ProjectManager {
  return moduleManager.getModule<ProjectManager>('project-manager')!;
}

function getFolderWatcher(): FolderWatcher {
  return moduleManager.getModule<FolderWatcher>('folder-watcher')!;
}

function getWorkMateReader(): WorkMateReader {
  return moduleManager.getModule<WorkMateReader>('workmate-reader')!;
}

function getAIAnalyzer(): AIAnalyzer {
  return moduleManager.getModule<AIAnalyzer>('ai-analyzer')!;
}

function registerIPC(): void {
  // --- Projects ---
  ipcMain.handle('project:list', () => getProjectManager().listProjects());
  ipcMain.handle('project:get', (_e, id: string) => getProjectManager().getProject(id));
  ipcMain.handle('project:create', (_e, data) => {
    const project = getProjectManager().createProject(data);
    getFolderWatcher().watchProject(project);
    return project;
  });
  ipcMain.handle('project:update', (_e, id: string, updates) => {
    const project = getProjectManager().updateProject(id, updates);
    if (project) {
      getFolderWatcher().unwatchProject(id);
      getFolderWatcher().watchProject(project);
    }
    return project;
  });
  ipcMain.handle('project:delete', (_e, id: string) => {
    getFolderWatcher().unwatchProject(id);
    return getProjectManager().deleteProject(id);
  });
  ipcMain.handle('project:selectFolder', async () => {
    if (!mainWindow) return null;
    const result = await dialog.showOpenDialog(mainWindow, {
      properties: ['openDirectory'],
      title: 'プロジェクトフォルダを選択',
    });
    return result.canceled ? null : result.filePaths[0];
  });

  // --- Progress ---
  ipcMain.handle('progress:get', (_e, projectId: string) =>
    getProjectManager().getProgressSnapshot(projectId)
  );
  ipcMain.handle('progress:getHistory', (_e, projectId: string) =>
    getProjectManager().getGanttData(projectId)
  );
  ipcMain.handle('progress:manualSet', (_e, projectId: string, phaseId: string, pageCount: number) => {
    getProjectManager().setManualProgress(projectId, phaseId, pageCount);
  });

  // Forward progress updates to renderer
  globalEventBus.on<{ projectId: string }>('progress:updated', (payload) => {
    mainWindow?.webContents.send('progress:updated', payload);
  });

  // --- Work Mate ---
  ipcMain.handle('workmate:getSummary', (_e, projectId: string) => {
    const project = getProjectManager().getProject(projectId);
    if (!project) return null;
    return getWorkMateReader().getSummary(project.createdAt, new Date().toISOString());
  });
  ipcMain.handle('workmate:isAvailable', () => getWorkMateReader().isAvailable());

  // --- AI Analysis ---
  ipcMain.handle('ai:analyze', async (_e, projectId: string) => {
    const pm = getProjectManager();
    const project = pm.getProject(projectId);
    if (!project) return { error: 'プロジェクトが見つかりません' };
    const snapshot = pm.getProgressSnapshot(projectId);
    const records = pm.getProgressRecords(projectId);
    const settings = pm.getSettings();
    let workMateData = null;
    try {
      workMateData = getWorkMateReader().getSummary(project.createdAt, new Date().toISOString());
    } catch { /* Work Mate not available */ }
    return getAIAnalyzer().analyze(project, snapshot!, records, workMateData, settings);
  });

  // --- Settings ---
  ipcMain.handle('settings:get', () => getProjectManager().getSettings());
  ipcMain.handle('settings:save', (_e, settings) => {
    getProjectManager().saveSettings(settings);
    const reader = getWorkMateReader();
    reader.setDataDir(settings.workMateDataDir);
  });
}

async function bootstrap(): Promise<void> {
  moduleManager = new ModuleManager(globalEventBus);
  moduleManager.register(new ProjectManager());
  moduleManager.register(new FolderWatcher());
  moduleManager.register(new WorkMateReader());
  moduleManager.register(new AIAnalyzer());

  await moduleManager.initializeAll();

  // Start watching existing projects
  const pm = getProjectManager();
  const watcher = getFolderWatcher();
  const projects = pm.listProjects().filter(p => !p.isArchived);
  for (const project of projects) {
    watcher.watchProject(project);
  }
}

app.whenReady().then(async () => {
  await bootstrap();
  createWindow();

  trayManager = new TrayManager();
  trayManager.create(mainWindow!);

  registerIPC();
});

app.on('before-quit', async () => {
  isQuitting = true;
  await moduleManager.disposeAll();
  trayManager.destroy();
});

app.on('window-all-closed', () => {
  // Do nothing - keep running in tray
});

app.on('activate', () => {
  if (mainWindow) {
    mainWindow.show();
  }
});

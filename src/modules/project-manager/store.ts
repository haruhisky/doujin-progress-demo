import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';
import { app } from 'electron';
import { Project, ProgressRecord, AppSettings, Phase } from './types';

const DATA_DIR = path.join(app.getPath('userData'), 'data');
const PROJECTS_DIR = path.join(DATA_DIR, 'projects');
const PROGRESS_DIR = path.join(DATA_DIR, 'progress');
const SETTINGS_PATH = path.join(DATA_DIR, 'settings.json');

function ensureDir(dir: string): void {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function generateId(): string {
  return crypto.randomUUID();
}

export class ProjectStore {
  private saveTimers: Map<string, ReturnType<typeof setTimeout>> = new Map();
  private static readonly SAVE_DEBOUNCE_MS = 5000;

  constructor() {
    ensureDir(PROJECTS_DIR);
    ensureDir(PROGRESS_DIR);
  }

  // --- Projects ---

  listProjects(): Project[] {
    ensureDir(PROJECTS_DIR);
    const files = fs.readdirSync(PROJECTS_DIR).filter(f => f.endsWith('.json'));
    return files.map(f => {
      const raw = fs.readFileSync(path.join(PROJECTS_DIR, f), 'utf-8');
      return JSON.parse(raw) as Project;
    }).sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));
  }

  getProject(id: string): Project | null {
    const filePath = path.join(PROJECTS_DIR, `${id}.json`);
    if (!fs.existsSync(filePath)) return null;
    return JSON.parse(fs.readFileSync(filePath, 'utf-8')) as Project;
  }

  createProject(data: {
    name: string;
    totalPages: number;
    deadline: string | null;
    rootFolder: string;
    phases: Omit<Phase, 'id'>[];
  }): Project {
    const now = new Date().toISOString();
    const project: Project = {
      id: generateId(),
      name: data.name,
      totalPages: data.totalPages,
      deadline: data.deadline,
      rootFolder: data.rootFolder,
      phases: data.phases.map(p => ({ ...p, id: generateId() })),
      createdAt: now,
      updatedAt: now,
      isArchived: false,
    };
    this.saveProject(project);
    ensureDir(path.join(PROGRESS_DIR, project.id));
    // 工程サブフォルダを自動生成
    for (const phase of project.phases) {
      if (phase.folderName) {
        ensureDir(path.join(project.rootFolder, phase.folderName));
      }
    }
    return project;
  }

  updateProject(id: string, updates: Partial<Pick<Project, 'name' | 'totalPages' | 'deadline' | 'rootFolder' | 'phases' | 'isArchived'>>): Project | null {
    const project = this.getProject(id);
    if (!project) return null;
    Object.assign(project, updates, { updatedAt: new Date().toISOString() });
    this.saveProject(project);
    return project;
  }

  deleteProject(id: string): boolean {
    const filePath = path.join(PROJECTS_DIR, `${id}.json`);
    if (!fs.existsSync(filePath)) return false;
    fs.unlinkSync(filePath);
    const progressDir = path.join(PROGRESS_DIR, id);
    if (fs.existsSync(progressDir)) {
      fs.rmSync(progressDir, { recursive: true });
    }
    return true;
  }

  private saveProject(project: Project): void {
    const filePath = path.join(PROJECTS_DIR, `${project.id}.json`);
    fs.writeFileSync(filePath, JSON.stringify(project, null, 2), 'utf-8');
  }

  // --- Progress Records ---

  getProgressRecords(projectId: string): ProgressRecord[] {
    const filePath = path.join(PROGRESS_DIR, projectId, 'records.json');
    if (!fs.existsSync(filePath)) return [];
    return JSON.parse(fs.readFileSync(filePath, 'utf-8')) as ProgressRecord[];
  }

  addProgressRecord(record: Omit<ProgressRecord, 'detectedAt'>): ProgressRecord {
    const full: ProgressRecord = {
      ...record,
      detectedAt: new Date().toISOString(),
    };
    const records = this.getProgressRecords(record.projectId);
    const exists = records.some(
      r => r.phaseId === full.phaseId && r.filename === full.filename
    );
    if (exists) return full;
    records.push(full);
    this.debouncedSaveRecords(record.projectId, records);
    return full;
  }

  setManualProgress(projectId: string, phaseId: string, pageCount: number): void {
    const records = this.getProgressRecords(projectId);
    const filtered = records.filter(r => r.phaseId !== phaseId);
    const now = new Date().toISOString();
    for (let i = 1; i <= pageCount; i++) {
      filtered.push({
        projectId,
        phaseId,
        pageNumber: i,
        filename: `manual_page_${i}`,
        detectedAt: now,
        fileModifiedAt: now,
      });
    }
    this.saveRecordsImmediate(projectId, filtered);
  }

  private debouncedSaveRecords(projectId: string, records: ProgressRecord[]): void {
    const existing = this.saveTimers.get(projectId);
    if (existing) clearTimeout(existing);
    const timer = setTimeout(() => {
      this.saveRecordsImmediate(projectId, records);
      this.saveTimers.delete(projectId);
    }, ProjectStore.SAVE_DEBOUNCE_MS);
    this.saveTimers.set(projectId, timer);
  }

  private saveRecordsImmediate(projectId: string, records: ProgressRecord[]): void {
    const dir = path.join(PROGRESS_DIR, projectId);
    ensureDir(dir);
    fs.writeFileSync(path.join(dir, 'records.json'), JSON.stringify(records, null, 2), 'utf-8');
  }

  flushAll(): void {
    for (const [projectId, timer] of this.saveTimers) {
      clearTimeout(timer);
      const records = this.getProgressRecords(projectId);
      this.saveRecordsImmediate(projectId, records);
    }
    this.saveTimers.clear();
  }

  // --- Settings ---

  getSettings(): AppSettings {
    if (!fs.existsSync(SETTINGS_PATH)) {
      return this.getDefaultSettings();
    }
    try {
      return JSON.parse(fs.readFileSync(SETTINGS_PATH, 'utf-8')) as AppSettings;
    } catch {
      return this.getDefaultSettings();
    }
  }

  saveSettings(settings: AppSettings): void {
    ensureDir(DATA_DIR);
    fs.writeFileSync(SETTINGS_PATH, JSON.stringify(settings, null, 2), 'utf-8');
  }

  private getDefaultSettings(): AppSettings {
    const defaultWorkMatePath = path.join(app.getPath('userData').replace(/[/\\][^/\\]+$/, ''), 'WorkMate', 'sessions');
    return {
      workMateDataDir: defaultWorkMatePath,
      llmProvider: null,
      llmApiKey: '',
      llmModel: '',
      defaultPhases: [
        { label: 'ネーム', folderName: 'ネーム', trackingMethod: 'manual', filePatterns: ['*.png', '*.jpg', '*.jpeg'], order: 0 },
        { label: '下書き', folderName: '下書き', trackingMethod: 'folder', filePatterns: ['*.psd', '*.clip', '*.png'], order: 1 },
        { label: 'ペン入れ', folderName: 'ペン入れ', trackingMethod: 'folder', filePatterns: ['*.psd', '*.clip', '*.png'], order: 2 },
        { label: '仕上げ', folderName: '仕上げ', trackingMethod: 'folder', filePatterns: ['*.psd', '*.clip', '*.png'], order: 3 },
      ],
    };
  }
}

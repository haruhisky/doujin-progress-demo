export interface Phase {
  id: string;
  label: string;
  folderName: string;
  trackingMethod: 'folder' | 'manual';
  filePatterns: string[];
  order: number;
}

export interface Project {
  id: string;
  name: string;
  totalPages: number;
  deadline: string | null;
  rootFolder: string;
  phases: Phase[];
  createdAt: string;
  updatedAt: string;
  isArchived: boolean;
}

export interface ProgressRecord {
  projectId: string;
  phaseId: string;
  pageNumber: number;
  filename: string;
  detectedAt: string;
  fileModifiedAt: string;
}

export interface ProgressSnapshot {
  projectId: string;
  phases: PhaseProgress[];
}

export interface PhaseProgress {
  phaseId: string;
  label: string;
  completedPages: number;
  totalPages: number;
  trackingMethod: 'folder' | 'manual';
}

export interface GanttDataPoint {
  date: string;
  phaseId: string;
  phaseLabel: string;
  pageNumber: number;
  filename: string;
}

export interface AppSettings {
  workMateDataDir: string;
  llmProvider: 'openai' | 'anthropic' | 'google' | null;
  llmApiKey: string;
  llmModel: string;
  defaultPhases: Omit<Phase, 'id'>[];
}

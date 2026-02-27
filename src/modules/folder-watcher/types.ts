export interface FileDetectedEvent {
  projectId: string;
  phaseId: string;
  pageNumber: number;
  filename: string;
  filePath: string;
  fileModifiedAt: string;
}

export interface WatcherConfig {
  projectId: string;
  phaseId: string;
  folderPath: string;
  filePatterns: string[];
}

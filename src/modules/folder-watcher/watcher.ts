import * as chokidar from 'chokidar';
import * as path from 'path';
import * as fs from 'fs';
import { EventBus } from '../../core/event-bus';
import { WatcherConfig, FileDetectedEvent } from './types';
import { extractPageNumber, matchesPattern } from './page-parser';

export class FolderWatcherInstance {
  private watcher: chokidar.FSWatcher | null = null;
  private config: WatcherConfig;
  private eventBus: EventBus;
  private fileCount: number = 0;

  constructor(config: WatcherConfig, eventBus: EventBus) {
    this.config = config;
    this.eventBus = eventBus;
  }

  start(): void {
    if (!fs.existsSync(this.config.folderPath)) {
      console.log(`Folder does not exist yet: ${this.config.folderPath}`);
      return;
    }

    this.watcher = chokidar.watch(this.config.folderPath, {
      ignoreInitial: false,
      depth: 0,
      awaitWriteFinish: {
        stabilityThreshold: 2000,
        pollInterval: 500,
      },
    });

    this.watcher.on('add', (filePath: string) => {
      this.handleFileAdd(filePath);
    });

    this.watcher.on('error', (error: Error) => {
      console.error(`Watcher error for ${this.config.folderPath}:`, error);
    });
  }

  private handleFileAdd(filePath: string): void {
    const filename = path.basename(filePath);

    if (!matchesPattern(filename, this.config.filePatterns)) {
      return;
    }

    let pageNumber = extractPageNumber(filename);
    if (pageNumber === -1) {
      this.fileCount++;
      pageNumber = this.fileCount;
    }

    let fileModifiedAt: string;
    try {
      const stat = fs.statSync(filePath);
      fileModifiedAt = stat.mtime.toISOString();
    } catch {
      fileModifiedAt = new Date().toISOString();
    }

    const event: FileDetectedEvent = {
      projectId: this.config.projectId,
      phaseId: this.config.phaseId,
      pageNumber,
      filename,
      filePath,
      fileModifiedAt,
    };

    this.eventBus.emit('file:detected', event);
  }

  async stop(): Promise<void> {
    if (this.watcher) {
      await this.watcher.close();
      this.watcher = null;
    }
  }
}

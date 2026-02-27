import * as fs from 'fs';
import { EventBus } from '../../core/event-bus';
import { AppModule } from '../../core/module-manager';
import { buildSummary } from './session-parser';
import { WorkMateSummary } from './types';
import { app } from 'electron';
import * as path from 'path';

export class WorkMateReader implements AppModule {
  readonly name = 'workmate-reader';
  private dataDir: string;

  constructor() {
    const userDataParent = app.getPath('userData').replace(/[/\\][^/\\]+$/, '');
    this.dataDir = path.join(userDataParent, 'WorkMate', 'sessions');
  }

  async initialize(_eventBus: EventBus): Promise<void> {
    // Read-only module, no initialization needed
  }

  async dispose(): Promise<void> {
    // Nothing to dispose
  }

  setDataDir(dir: string): void {
    this.dataDir = dir;
  }

  isAvailable(): boolean {
    return fs.existsSync(this.dataDir);
  }

  getSummary(startISO: string, endISO: string): WorkMateSummary | null {
    if (!this.isAvailable()) return null;
    return buildSummary(this.dataDir, startISO, endISO);
  }
}

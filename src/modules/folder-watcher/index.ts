import * as path from 'path';
import { EventBus } from '../../core/event-bus';
import { AppModule } from '../../core/module-manager';
import { FolderWatcherInstance } from './watcher';
import { Project } from '../project-manager/types';

export class FolderWatcher implements AppModule {
  readonly name = 'folder-watcher';
  private eventBus!: EventBus;
  private watchers: Map<string, FolderWatcherInstance[]> = new Map();

  async initialize(eventBus: EventBus): Promise<void> {
    this.eventBus = eventBus;
  }

  watchProject(project: Project): void {
    this.unwatchProject(project.id);
    const instances: FolderWatcherInstance[] = [];

    for (const phase of project.phases) {
      if (phase.trackingMethod !== 'folder') continue;

      const folderPath = path.join(project.rootFolder, phase.folderName);
      const instance = new FolderWatcherInstance(
        {
          projectId: project.id,
          phaseId: phase.id,
          folderPath,
          filePatterns: phase.filePatterns,
        },
        this.eventBus
      );
      instance.start();
      instances.push(instance);
    }

    this.watchers.set(project.id, instances);
  }

  unwatchProject(projectId: string): void {
    const instances = this.watchers.get(projectId);
    if (instances) {
      for (const instance of instances) {
        instance.stop();
      }
      this.watchers.delete(projectId);
    }
  }

  async dispose(): Promise<void> {
    for (const [projectId] of this.watchers) {
      this.unwatchProject(projectId);
    }
  }
}

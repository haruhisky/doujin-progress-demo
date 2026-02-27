import { EventBus } from '../../core/event-bus';
import { AppModule } from '../../core/module-manager';
import { ProjectStore } from './store';
import { Project, ProgressRecord, ProgressSnapshot, PhaseProgress, GanttDataPoint } from './types';

export class ProjectManager implements AppModule {
  readonly name = 'project-manager';
  private store!: ProjectStore;
  private eventBus!: EventBus;

  async initialize(eventBus: EventBus): Promise<void> {
    this.eventBus = eventBus;
    this.store = new ProjectStore();

    eventBus.on<{ projectId: string; phaseId: string; pageNumber: number; filename: string; fileModifiedAt: string }>(
      'file:detected',
      (payload) => {
        this.store.addProgressRecord({
          projectId: payload.projectId,
          phaseId: payload.phaseId,
          pageNumber: payload.pageNumber,
          filename: payload.filename,
          fileModifiedAt: payload.fileModifiedAt,
        });
        eventBus.emit('progress:updated', { projectId: payload.projectId });
      }
    );
  }

  async dispose(): Promise<void> {
    this.store.flushAll();
  }

  listProjects(): Project[] {
    return this.store.listProjects();
  }

  getProject(id: string): Project | null {
    return this.store.getProject(id);
  }

  createProject(data: Parameters<ProjectStore['createProject']>[0]): Project {
    const project = this.store.createProject(data);
    this.eventBus.emit('project:created', { project });
    return project;
  }

  updateProject(id: string, updates: Parameters<ProjectStore['updateProject']>[1]): Project | null {
    const project = this.store.updateProject(id, updates);
    if (project) {
      this.eventBus.emit('project:updated', { project });
    }
    return project;
  }

  deleteProject(id: string): boolean {
    const result = this.store.deleteProject(id);
    if (result) {
      this.eventBus.emit('project:deleted', { projectId: id });
    }
    return result;
  }

  getProgressSnapshot(projectId: string): ProgressSnapshot | null {
    const project = this.store.getProject(projectId);
    if (!project) return null;
    const records = this.store.getProgressRecords(projectId);

    const phases: PhaseProgress[] = project.phases
      .sort((a, b) => a.order - b.order)
      .map(phase => {
        const phaseRecords = records.filter(r => r.phaseId === phase.id);
        const uniquePages = new Set(phaseRecords.map(r => r.pageNumber));
        return {
          phaseId: phase.id,
          label: phase.label,
          completedPages: uniquePages.size,
          totalPages: project.totalPages,
          trackingMethod: phase.trackingMethod,
        };
      });

    return { projectId, phases };
  }

  getGanttData(projectId: string): GanttDataPoint[] {
    const project = this.store.getProject(projectId);
    if (!project) return [];
    const records = this.store.getProgressRecords(projectId);

    return records.map(r => {
      const phase = project.phases.find(p => p.id === r.phaseId);
      return {
        date: r.detectedAt.split('T')[0],
        phaseId: r.phaseId,
        phaseLabel: phase?.label ?? '不明',
        pageNumber: r.pageNumber,
        filename: r.filename,
      };
    }).sort((a, b) => a.date.localeCompare(b.date));
  }

  setManualProgress(projectId: string, phaseId: string, pageCount: number): void {
    this.store.setManualProgress(projectId, phaseId, pageCount);
    this.eventBus.emit('progress:updated', { projectId });
  }

  getProgressRecords(projectId: string): ProgressRecord[] {
    return this.store.getProgressRecords(projectId);
  }

  getSettings() {
    return this.store.getSettings();
  }

  saveSettings(settings: Parameters<ProjectStore['saveSettings']>[0]) {
    this.store.saveSettings(settings);
  }
}

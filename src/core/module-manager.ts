import { EventBus } from './event-bus';

export interface AppModule {
  name: string;
  initialize(eventBus: EventBus): Promise<void>;
  dispose(): Promise<void>;
}

export class ModuleManager {
  private modules: Map<string, AppModule> = new Map();
  private eventBus: EventBus;

  constructor(eventBus: EventBus) {
    this.eventBus = eventBus;
  }

  register(module: AppModule): void {
    if (this.modules.has(module.name)) {
      throw new Error(`Module "${module.name}" is already registered`);
    }
    this.modules.set(module.name, module);
  }

  async initializeAll(): Promise<void> {
    for (const [name, module] of this.modules) {
      try {
        await module.initialize(this.eventBus);
        console.log(`Module "${name}" initialized`);
      } catch (error) {
        console.error(`Failed to initialize module "${name}":`, error);
        throw error;
      }
    }
  }

  async disposeAll(): Promise<void> {
    const entries = Array.from(this.modules.entries()).reverse();
    for (const [name, module] of entries) {
      try {
        await module.dispose();
        console.log(`Module "${name}" disposed`);
      } catch (error) {
        console.error(`Failed to dispose module "${name}":`, error);
      }
    }
    this.modules.clear();
  }

  getModule<T extends AppModule>(name: string): T | undefined {
    return this.modules.get(name) as T | undefined;
  }
}

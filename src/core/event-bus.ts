type EventHandler<T = unknown> = (payload: T) => void;

export class EventBus {
  private handlers: Map<string, Set<EventHandler>> = new Map();

  on<T = unknown>(event: string, handler: EventHandler<T>): () => void {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, new Set());
    }
    const handlers = this.handlers.get(event)!;
    handlers.add(handler as EventHandler);
    return () => {
      handlers.delete(handler as EventHandler);
    };
  }

  once<T = unknown>(event: string, handler: EventHandler<T>): () => void {
    const wrappedHandler: EventHandler<T> = (payload) => {
      unsubscribe();
      handler(payload);
    };
    const unsubscribe = this.on(event, wrappedHandler);
    return unsubscribe;
  }

  emit<T = unknown>(event: string, payload: T): void {
    const handlers = this.handlers.get(event);
    if (!handlers) return;
    for (const handler of handlers) {
      try {
        handler(payload);
      } catch (error) {
        console.error(`Error in event handler for "${event}":`, error);
      }
    }
  }

  off(event: string): void {
    this.handlers.delete(event);
  }

  clear(): void {
    this.handlers.clear();
  }
}

export const globalEventBus = new EventBus();

import { useState, useEffect, useCallback } from 'react';

export function useProgress(projectId) {
  const [snapshot, setSnapshot] = useState(null);
  const [ganttData, setGanttData] = useState([]);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    if (!projectId) return;
    setLoading(true);
    try {
      const [snap, gantt] = await Promise.all([
        window.electronAPI.getProgress(projectId),
        window.electronAPI.getGanttData(projectId),
      ]);
      setSnapshot(snap);
      setGanttData(gantt);
    } catch (err) {
      console.error('Failed to load progress:', err);
    } finally {
      setLoading(false);
    }
  }, [projectId]);

  useEffect(() => { refresh(); }, [refresh]);

  // Listen for real-time updates
  useEffect(() => {
    if (!projectId) return;
    const unsub = window.electronAPI.onProgressUpdated((data) => {
      if (data.projectId === projectId) {
        refresh();
      }
    });
    return unsub;
  }, [projectId, refresh]);

  return { snapshot, ganttData, loading, refresh };
}

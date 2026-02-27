import { useState, useCallback } from 'react';

export function useAIAnalysis() {
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const analyze = useCallback(async (projectId) => {
    setLoading(true);
    setResult(null);
    try {
      const res = await window.electronAPI.analyzeProject(projectId);
      setResult(res);
    } catch (err) {
      setResult({ success: false, text: '', error: err.message });
    } finally {
      setLoading(false);
    }
  }, []);

  return { result, loading, analyze };
}

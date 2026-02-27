import React from 'react';
import { useAIAnalysis } from '../hooks/useAIAnalysis';
import '../styles/ai-panel.css';

export default function AIAnalysisPanel({ projectId }) {
  const { result, loading, analyze } = useAIAnalysis();

  return (
    <div className="ai-panel">
      <div className="ai-panel-header">
        <h3>AI分析</h3>
        <button
          className="btn btn-primary"
          onClick={() => analyze(projectId)}
          disabled={loading}
        >
          {loading ? '分析中...' : '分析を実行'}
        </button>
      </div>

      {loading && (
        <div className="ai-loading">
          <div className="spinner" />
          <p>AIが進捗を分析しています...</p>
        </div>
      )}

      {result && !loading && (
        <div className={`ai-result ${result.success ? '' : 'ai-result-error'}`}>
          {result.success ? (
            <div className="ai-result-text">{result.text}</div>
          ) : (
            <div className="ai-error">{result.error}</div>
          )}
        </div>
      )}

      {!result && !loading && (
        <p className="ai-hint">「分析を実行」をクリックすると、AIが現在の進捗と締切を分析し、現実的な見通しと改善提案を返します。</p>
      )}
    </div>
  );
}

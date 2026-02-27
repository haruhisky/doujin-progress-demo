import React, { useState } from 'react';
import ProgressBar from './common/ProgressBar';

const PHASE_COLORS = ['#f59e0b', '#3b82f6', '#8b5cf6', '#10b981', '#ef4444', '#6366f1'];

export default function PhaseProgressBar({ phases, projectId }) {
  const [editingPhase, setEditingPhase] = useState(null);
  const [manualValue, setManualValue] = useState(0);

  const handleManualSet = async (phaseId) => {
    await window.electronAPI.setManualProgress(projectId, phaseId, manualValue);
    setEditingPhase(null);
  };

  return (
    <div className="phase-progress-bars">
      {phases.map((phase, i) => (
        <div key={phase.phaseId} className="phase-progress-item">
          <ProgressBar
            value={phase.completedPages}
            max={phase.totalPages}
            label={phase.label}
            color={PHASE_COLORS[i % PHASE_COLORS.length]}
          />
          {phase.trackingMethod === 'manual' && (
            <div className="manual-control">
              {editingPhase === phase.phaseId ? (
                <div className="manual-input-group">
                  <input
                    type="number"
                    value={manualValue}
                    onChange={(e) => setManualValue(parseInt(e.target.value) || 0)}
                    min="0"
                    max={phase.totalPages}
                  />
                  <button className="btn btn-sm btn-primary" onClick={() => handleManualSet(phase.phaseId)}>設定</button>
                  <button className="btn btn-sm" onClick={() => setEditingPhase(null)}>取消</button>
                </div>
              ) : (
                <button
                  className="btn btn-sm"
                  onClick={() => { setEditingPhase(phase.phaseId); setManualValue(phase.completedPages); }}
                >
                  手動設定
                </button>
              )}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

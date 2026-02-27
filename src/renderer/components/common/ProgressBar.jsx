import React from 'react';

export default function ProgressBar({ value, max, label, color = '#4a9eff' }) {
  const percent = max > 0 ? Math.round((value / max) * 100) : 0;

  return (
    <div className="progress-bar-container">
      {label && <span className="progress-bar-label">{label}</span>}
      <div className="progress-bar-track">
        <div
          className="progress-bar-fill"
          style={{ width: `${percent}%`, backgroundColor: color }}
        />
      </div>
      <span className="progress-bar-text">{value}/{max} ({percent}%)</span>
    </div>
  );
}

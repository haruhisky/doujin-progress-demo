import React from 'react';

export default function DatePicker({ value, onChange, label, clearable = false }) {
  return (
    <div className="date-picker">
      {label && <label className="date-picker-label">{label}</label>}
      <div className="date-picker-input-group">
        <input
          type="date"
          value={value || ''}
          onChange={(e) => onChange(e.target.value || null)}
        />
        {clearable && value && (
          <button className="date-picker-clear" onClick={() => onChange(null)}>×</button>
        )}
      </div>
    </div>
  );
}

import React, { useMemo, useState } from 'react';
import '../styles/gantt-chart.css';

const CHART_PADDING = { top: 40, right: 20, bottom: 40, left: 80 };
const ROW_HEIGHT = 40;
const DOT_RADIUS = 6;
const PHASE_COLORS = ['#f59e0b', '#3b82f6', '#8b5cf6', '#10b981', '#ef4444', '#6366f1'];

export default function GanttChart({ data, phases, deadline }) {
  const [tooltip, setTooltip] = useState(null);

  const { dates, phaseLabels, width, height } = useMemo(() => {
    if (!data || data.length === 0) return { dates: [], phaseLabels: [], width: 600, height: 200 };

    const allDates = new Set(data.map(d => d.date));
    if (deadline) allDates.add(deadline.split('T')[0]);
    const today = new Date().toISOString().split('T')[0];
    allDates.add(today);

    const sorted = Array.from(allDates).sort();
    const labels = phases.map(p => p.label);

    return {
      dates: sorted,
      phaseLabels: labels,
      width: Math.max(600, sorted.length * 50 + CHART_PADDING.left + CHART_PADDING.right),
      height: labels.length * ROW_HEIGHT + CHART_PADDING.top + CHART_PADDING.bottom,
    };
  }, [data, phases, deadline]);

  if (!data || data.length === 0) {
    return <div className="gantt-empty">まだ進捗データがありません</div>;
  }

  const xScale = (date) => {
    const idx = dates.indexOf(date);
    if (idx === -1) return CHART_PADDING.left;
    const range = width - CHART_PADDING.left - CHART_PADDING.right;
    return CHART_PADDING.left + (idx / Math.max(1, dates.length - 1)) * range;
  };

  const yScale = (phaseLabel) => {
    const idx = phaseLabels.indexOf(phaseLabel);
    return CHART_PADDING.top + idx * ROW_HEIGHT + ROW_HEIGHT / 2;
  };

  const today = new Date().toISOString().split('T')[0];
  const deadlineDate = deadline ? deadline.split('T')[0] : null;

  return (
    <div className="gantt-chart-wrapper">
      <svg width={width} height={height} className="gantt-chart-svg">
        {/* Grid lines */}
        {phaseLabels.map((label, i) => (
          <g key={label}>
            <line
              x1={CHART_PADDING.left}
              y1={CHART_PADDING.top + i * ROW_HEIGHT}
              x2={width - CHART_PADDING.right}
              y2={CHART_PADDING.top + i * ROW_HEIGHT}
              stroke="#e5e7eb"
              strokeDasharray="4"
            />
            <text
              x={CHART_PADDING.left - 10}
              y={yScale(label)}
              textAnchor="end"
              dominantBaseline="middle"
              fontSize="13"
              fill="#374151"
            >
              {label}
            </text>
          </g>
        ))}

        {/* Date labels */}
        {dates.filter((_, i) => i % Math.max(1, Math.floor(dates.length / 10)) === 0 || i === dates.length - 1).map(date => (
          <text
            key={date}
            x={xScale(date)}
            y={height - 10}
            textAnchor="middle"
            fontSize="11"
            fill="#6b7280"
          >
            {date.slice(5)}
          </text>
        ))}

        {/* Today line */}
        {dates.includes(today) && (
          <line
            x1={xScale(today)} y1={CHART_PADDING.top - 10}
            x2={xScale(today)} y2={height - CHART_PADDING.bottom}
            stroke="#3b82f6" strokeWidth="2" strokeDasharray="6"
          />
        )}

        {/* Deadline line */}
        {deadlineDate && dates.includes(deadlineDate) && (
          <line
            x1={xScale(deadlineDate)} y1={CHART_PADDING.top - 10}
            x2={xScale(deadlineDate)} y2={height - CHART_PADDING.bottom}
            stroke="#ef4444" strokeWidth="2" strokeDasharray="6"
          />
        )}

        {/* Data points */}
        {data.map((point, i) => {
          const phaseIdx = phaseLabels.indexOf(point.phaseLabel);
          return (
            <circle
              key={i}
              cx={xScale(point.date)}
              cy={yScale(point.phaseLabel)}
              r={DOT_RADIUS}
              fill={PHASE_COLORS[phaseIdx % PHASE_COLORS.length]}
              opacity="0.8"
              style={{ cursor: 'pointer' }}
              onMouseEnter={(e) => setTooltip({
                x: e.clientX,
                y: e.clientY,
                text: `${point.phaseLabel} - ${point.filename} (p.${point.pageNumber})`,
              })}
              onMouseLeave={() => setTooltip(null)}
            />
          );
        })}

        {/* Legend: Today / Deadline */}
        <text x={CHART_PADDING.left} y={CHART_PADDING.top - 20} fontSize="11" fill="#3b82f6">―― 今日</text>
        {deadlineDate && (
          <text x={CHART_PADDING.left + 60} y={CHART_PADDING.top - 20} fontSize="11" fill="#ef4444">―― 締切</text>
        )}
      </svg>

      {tooltip && (
        <div
          className="gantt-tooltip"
          style={{ left: tooltip.x + 12, top: tooltip.y - 10 }}
        >
          {tooltip.text}
        </div>
      )}
    </div>
  );
}

import * as fs from 'fs';
import * as path from 'path';
import { WorkMateDailyRecord, WorkMateSummary } from './types';

export function loadDailyRecord(sessionsDir: string, date: string): WorkMateDailyRecord | null {
  const filePath = path.join(sessionsDir, `${date}.json`);
  if (!fs.existsSync(filePath)) return null;
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  } catch {
    return null;
  }
}

export function getDateRange(startISO: string, endISO: string): string[] {
  const dates: string[] = [];
  const start = new Date(startISO);
  const end = new Date(endISO);
  start.setHours(0, 0, 0, 0);
  end.setHours(0, 0, 0, 0);

  const current = new Date(start);
  while (current <= end) {
    dates.push(current.toISOString().split('T')[0]);
    current.setDate(current.getDate() + 1);
  }
  return dates;
}

export function buildSummary(sessionsDir: string, startISO: string, endISO: string): WorkMateSummary | null {
  const dates = getDateRange(startISO, endISO);
  const records: WorkMateDailyRecord[] = [];

  for (const date of dates) {
    const record = loadDailyRecord(sessionsDir, date);
    if (record) records.push(record);
  }

  if (records.length === 0) return null;

  const appTotals = new Map<string, number>();
  const dailyBreakdown: { date: string; workHours: number; breakHours: number }[] = [];

  let totalWorkSec = 0;
  let totalBreakSec = 0;

  for (const record of records) {
    const workSec = record.summary.totalWorkSec;
    const breakSec = record.summary.totalBreakSec;
    totalWorkSec += workSec;
    totalBreakSec += breakSec;

    dailyBreakdown.push({
      date: record.date,
      workHours: Math.round(workSec / 36) / 100,
      breakHours: Math.round(breakSec / 36) / 100,
    });

    for (const app of record.summary.topApps) {
      appTotals.set(app.app, (appTotals.get(app.app) || 0) + app.durationSec);
    }
  }

  const topApps = Array.from(appTotals.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)
    .map(([app, sec]) => ({ app, totalHours: Math.round(sec / 36) / 100 }));

  return {
    totalDays: records.length,
    avgWorkHoursPerDay: Math.round((totalWorkSec / records.length / 36)) / 100,
    totalWorkHours: Math.round(totalWorkSec / 36) / 100,
    topApps,
    dailyBreakdown,
  };
}

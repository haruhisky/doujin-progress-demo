export interface WorkMateSession {
  app: string;
  processName: string;
  category: string;
  startTime: string;
  endTime: string;
  durationSec: number;
}

export interface WorkMateDailyRecord {
  date: string;
  version: string;
  sessions: WorkMateSession[];
  summary: {
    date: string;
    totalWorkSec: number;
    totalBreakSec: number;
    productivityRatio: number;
    topApps: { app: string; durationSec: number }[];
  };
}

export interface WorkMateSummary {
  totalDays: number;
  avgWorkHoursPerDay: number;
  totalWorkHours: number;
  topApps: { app: string; totalHours: number }[];
  dailyBreakdown: { date: string; workHours: number; breakHours: number }[];
}

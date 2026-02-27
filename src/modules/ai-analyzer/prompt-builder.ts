import { Project, ProgressSnapshot, ProgressRecord } from '../project-manager/types';
import { WorkMateSummary } from '../workmate-reader/types';

export function buildAnalysisPrompt(
  project: Project,
  snapshot: ProgressSnapshot,
  records: ProgressRecord[],
  workMateData: WorkMateSummary | null
): string {
  const now = new Date();
  const deadlineStr = project.deadline
    ? `${project.deadline}（残り${getDaysUntil(project.deadline)}日）`
    : '未設定';

  const phaseLines = snapshot.phases.map(p => {
    const phaseRecords = records.filter(r => r.phaseId === p.phaseId);
    const speed = calculateSpeed(phaseRecords);
    return `- ${p.label}: ${p.completedPages}/${p.totalPages}ページ完了` +
      (speed ? ` (${speed.pagesPerDay.toFixed(1)}ページ/日, ${speed.daysUsed}日間)` : '');
  }).join('\n');

  let workMateSection = '';
  if (workMateData) {
    const appLines = workMateData.topApps.slice(0, 5)
      .map(a => `  - ${a.app}: ${a.totalHours}h`)
      .join('\n');
    workMateSection = `
## Work Mate作業データ
- 計測日数: ${workMateData.totalDays}日
- 平均作業時間: ${workMateData.avgWorkHoursPerDay}h/日
- 総作業時間: ${workMateData.totalWorkHours}h
- 使用アプリTOP5:
${appLines}`;
  }

  return `以下のプロジェクトデータを分析し、締切に間に合うかを判定してください。
現実的なペース予測と、間に合わない場合の具体的な改善提案を含めてください。

## プロジェクト情報
- プロジェクト名: ${project.name}
- 総ページ数: ${project.totalPages}ページ
- 締切: ${deadlineStr}
- 作成日: ${project.createdAt.split('T')[0]}
- 現在日: ${now.toISOString().split('T')[0]}

## 工程別進捗
${phaseLines}
${workMateSection}

---
上記データに基づき、以下の形式で分析結果を返してください:
1. 各工程の完了見込み日
2. 締切に間に合うかの判定（○/△/×）
3. ボトルネックとなっている工程
4. 具体的な改善提案（Work Mateデータがある場合は作業時間の内訳に基づいた提案を含める）`;
}

function getDaysUntil(deadlineISO: string): number {
  const now = new Date();
  const deadline = new Date(deadlineISO);
  const diffMs = deadline.getTime() - now.getTime();
  return Math.ceil(diffMs / (1000 * 60 * 60 * 24));
}

function calculateSpeed(records: ProgressRecord[]): { pagesPerDay: number; daysUsed: number } | null {
  if (records.length < 2) return null;
  const sorted = records.sort((a, b) => a.detectedAt.localeCompare(b.detectedAt));
  const first = new Date(sorted[0].detectedAt);
  const last = new Date(sorted[sorted.length - 1].detectedAt);
  const days = Math.max(1, (last.getTime() - first.getTime()) / (1000 * 60 * 60 * 24));
  const uniquePages = new Set(records.map(r => r.pageNumber)).size;
  return { pagesPerDay: uniquePages / days, daysUsed: Math.ceil(days) };
}

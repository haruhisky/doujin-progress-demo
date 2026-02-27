import * as path from 'path';

const PAGE_REGEX = /(?:page|p|ページ)?0*(\d+)/i;

/**
 * ファイル名からページ番号を抽出する
 * 例: "page01.png" → 1, "P003.psd" → 3, "05.clip" → 5
 * 抽出失敗時は -1 を返す
 */
export function extractPageNumber(filename: string): number {
  const name = path.basename(filename, path.extname(filename));
  const match = name.match(PAGE_REGEX);
  if (match) {
    return parseInt(match[1], 10);
  }
  return -1;
}

/**
 * ファイル拡張子がパターンにマッチするか
 * パターン例: ["*.png", "*.psd", "*.clip"]
 */
export function matchesPattern(filename: string, patterns: string[]): boolean {
  const ext = path.extname(filename).toLowerCase();
  return patterns.some(pattern => {
    const patternExt = pattern.replace('*', '').toLowerCase();
    return ext === patternExt;
  });
}

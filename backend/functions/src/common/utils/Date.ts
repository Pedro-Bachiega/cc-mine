export function getSecondsDiff(start: Date, end: Date = new Date()): number {
  return Math.abs(start.getTime() - end.getTime()) / 1000;
}

export function noop(): void {
}

export function isString(value: unknown): value is string {
  return typeof value === "string" || value instanceof String;
}

export function isNumber(value: unknown): value is number {
  return typeof value === "number" || value instanceof Number;
}

export const uniqId = (function() {
  let counter = 0;
  return function(): number {
    counter += 1;
    return counter;
  };
})();

export function areStrsEqual(a: unknown, b: unknown): boolean {
  return isString(a) && isString(b) && (a.localeCompare(b) === 0);
}

export function areFloatsEqual(a: number, b: number): boolean {
  return Math.abs(a - b) < Number.EPSILON;
}

export function toFinitFloat(value: string, defaultValue = 0.0) {
  const result = Number.parseFloat(value);
  return Number.isFinite(result) ? result : defaultValue;
}

export function toFinitInt(value: string, defaultValue = 0) {
  const result = Number.parseInt(value);
  return Number.isFinite(result) ? result : defaultValue;
}

export function valueOrDefault<T>(value: T | null | undefined, defaultValue: T) {
  return (value === null || value === undefined) ? defaultValue : value;
}

export function isNil(value: unknown): value is (null | undefined) {
  return value === null || value === undefined;
}

export function isNotNil<T>(value: T | null | undefined): value is T {
  return !isNil(value);
}

export function stringToValidNumber(value: string): number {
  const num = Number.parseFloat(value);
  // Also: isFinite(NaN) returns false
  return Number.isFinite(num) ? num : 0;
}

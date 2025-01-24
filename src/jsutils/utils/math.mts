export function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}

export function copy3dVector(vector: vector3d) {
  return Qt.vector3d(vector.x, vector.y, vector.z);
}

export function approxEqual(a: number, b: number): boolean {
  return Math.abs(a - b) < Number.EPSILON;
}

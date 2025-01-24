interface vector3d {
  x: number;
  y: number;
  z: number;

  length(): number;
  fuzzyEquals(other: vector3d, epsilon?: real): boolean;
}

import { Validator } from "./Validator.mts";
import { ValidatorResult } from "./ValidatorResult.mts";

export type ValidatorsMap = { [key: string]: Validator };

export class ValidationError extends Error {}

export function isPlainObject(value: unknown): value is { [key: string]: unknown } {
  return value === Object(value);
}

export function concat(a: ValidatorResult, b: ValidatorResult): ValidatorResult {
  return new ValidatorResult([...a.errors(), ...b.errors()]);
}

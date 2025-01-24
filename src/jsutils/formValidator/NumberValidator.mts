import { isNumber, noop } from "../utils/common.mts";

import { ValidationError } from "./common.mts";
import { Validator, IValidatorCallbacks } from "./Validator.mts";
import { ValidatorResult } from "./ValidatorResult.mts";

export class NumberValidator extends Validator {
  private _validators: Array<(value: unknown) => void> = [];
  private _throwIfNotNumber: (value: unknown) => asserts value is number = noop;

  constructor(config: { notNumberMessage?: string; } = {}) {
    super();
    this._throwIfNotNumber = (value: unknown) => {
      if (!isNumber(value)) {
        throw new ValidationError(config?.notNumberMessage || "The value should be a number");
      }
    };
    this._validators.push(this._throwIfNotNumber);
  }

  min(min: number, config: { message?: string } = {}): NumberValidator {
    this._validators.push((value: unknown) => {
      this._throwIfNotNumber(value);
      if (value < min) {
        throw new ValidationError(config?.message || `The value shouldn't be less than ${min}`)
      }
    });
    return this;
  }

  finite(config: { message?: string } = {}): NumberValidator {
    this._validators.push((value: unknown) => {
      this._throwIfNotNumber(value);
      if (!Number.isFinite(value)) {
        throw new ValidationError(config?.message || `The value should be a finite number`)
      }
    });
    return this;
  }

  integer(config: { message?: string } = {}): NumberValidator {
    this._validators.push((value: unknown) => {
      this._throwIfNotNumber(value);
      if (!Number.isInteger(value)) {
        throw new ValidationError(config?.message || `The value should be an integer`)
      }
    });
    return this;
  }

  on(config: IValidatorCallbacks = {}): NumberValidator {
    this.registerCallbacks(config);
    return this;
  }

  validate(value: unknown): ValidatorResult {
    this.reset();
    try {
      this._validators.forEach((validator) => {
        validator(value);
      });
    } catch(error) {
      if (error instanceof ValidationError) {
        this.failure([error.message]);
        return new ValidatorResult([error.message]);
      }
      throw error;
    }
    this.success();
    return new ValidatorResult();
  }
}

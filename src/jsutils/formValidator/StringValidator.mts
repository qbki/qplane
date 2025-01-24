import { isString, noop } from "../utils/common.mts";

import { ValidationError } from "./common.mts";
import { Validator, IValidatorCallbacks } from "./Validator.mts";
import { ValidatorResult } from "./ValidatorResult.mts";

export class StringValidator extends Validator {
  private _validators: Array<(value: unknown) => void> = [];
  private _throwIfNotString: (value: unknown) => asserts value is string = noop;

  constructor(config: { wrongTypeMessage?: string } = {}) {
    super();
    this._throwIfNotString = (value) => {
      if (!isString(value)) {
        throw new ValidationError(config?.wrongTypeMessage || "The value should be a string");
      }
    };
    this._validators.push(this._throwIfNotString);
  }

  on(config: IValidatorCallbacks = {}): StringValidator {
    this.registerCallbacks(config);
    return this;
  }

  notEmpty(config: { message?: string } = {}): StringValidator {
    this._validators.push((value) => {
      this._throwIfNotString(value);
      if (value.length === 0) {
        throw new ValidationError(config.message || "An empty string is not allowed");
      }
    });
    return this;
  }

  unique(list: Array<string>, config: { message?: string } = {}) {
    const { message } = config;
    const listCopy = [...list];
    this._validators.push((value) => {
      this._throwIfNotString(value);
      if (listCopy.includes(value)) {
        throw new ValidationError(message || "The value should be unique");
      }
    })
    return this;
  }

  validate(value: unknown): ValidatorResult {
    this.reset();
    try {
      this._validators.forEach((validator) => {
        validator(value);
      });
      this.success();
    } catch(error) {
      if (error instanceof ValidationError) {
        this.failure([error.message]);
        return new ValidatorResult([error.message]);
      }
      throw error;
    }
    return new ValidatorResult();
  }
}

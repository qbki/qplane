import { noop } from "../utils/common.mts";

import { ValidationError } from "./common.mts";
import { Validator, IValidatorCallbacks } from "./Validator.mts";
import { ValidatorResult } from "./ValidatorResult.mts";

export class Vector3DValidator extends Validator {
  private _validators: Array<(value: unknown) => void> = [];
  private _throwIfNotVector: (value: unknown) => asserts value is vector3d = noop;

  private static _vector3dConstructor = Qt.vector3d(0, 0, 0).constructor;

  constructor(config: { notNumberMessage?: string; } = {}) {
    super();
    this._throwIfNotVector = function(value: unknown) {
      if (!(value instanceof Vector3DValidator._vector3dConstructor)) {
        throw new ValidationError(config?.notNumberMessage || "The value should be a vector3d");
      }
    };
    this._throwIfNotVector = this._throwIfNotVector.bind(this);
    this._validators.push(this._throwIfNotVector);
  }

  notZero(config: { message?: string } = {}): Vector3DValidator {
    this._validators.push((value: unknown) => {
      this._throwIfNotVector(value);
      if (value.fuzzyEquals(Qt.vector3d(0, 0, 0))) {
        throw new ValidationError(config?.message || `The vector shouldn't be zero`)
      }
    });
    return this;
  }

  min(minValue: vector3d, config: { message?: string } = {}) {
    this._validators.push((value: unknown) => {
      this._throwIfNotVector(value);
      if (value.x <= minValue.x || value.y <= minValue.y || value.z <= minValue.z) {
        throw new ValidationError(config?.message || `Components of the vector shouldn't be less than ${minValue}`)
      }
    });
    return this;
  }

  max(maxValue: vector3d, config: { message?: string } = {}) {
    this._validators.push((value: unknown) => {
      this._throwIfNotVector(value);
      if (value.x >= maxValue.x || value.y >= maxValue.y || value.z >= maxValue.z) {
        throw new ValidationError(config?.message || `Components of the vector shouldn't be more than ${maxValue}`)
      }
    });
    return this;
  }

  on(config: IValidatorCallbacks = {}): Vector3DValidator {
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

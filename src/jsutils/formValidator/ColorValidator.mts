import { ValidationError } from "./common.mts";
import { Validator, IValidatorCallbacks } from "./Validator.mts";
import { ValidatorResult } from "./ValidatorResult.mts";

export class ColorValidator extends Validator {
  private _validators: Array<(value: unknown) => void> = [];

  private static _colorConstructor = Qt.color("#ffffff").constructor;

  constructor(config: {
    wrongTypeMessage?: string;
    notValidMessage?: string;
  } = {}) {
    super();
    function throwIfNotColor(value: unknown): asserts value is color  {
      if (!(value instanceof ColorValidator._colorConstructor)) {
        throw new ValidationError(config?.wrongTypeMessage || "The value should be a color");
      }
    };
    function throwIfNotValid(value: unknown): void {
      throwIfNotColor(value);
      if (!value.valid) {
        throw new ValidationError(config?.notValidMessage || "The value should be a valid color");
      }
    };
    this._validators.push(throwIfNotValid);
  }

  on(config: IValidatorCallbacks = {}): ColorValidator {
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

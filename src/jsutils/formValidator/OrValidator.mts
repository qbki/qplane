import { Validator, IValidatorCallbacks } from "./Validator.mts";
import { ValidatorResult } from "./ValidatorResult.mts";
import { concat } from "./common.mts";

export class OrValidator extends Validator {
  private _validators: Array<Validator> = [];

  constructor(...args: Array<Validator>) {
    super();
    this._validators = args;
  }

  on(config: IValidatorCallbacks = {}): OrValidator {
    this.registerCallbacks(config);
    return this;
  }

  validate(value: unknown): ValidatorResult {
    this.reset();
    const errors = this._validators
      .map((validator) => validator.validate(value));

    const hasAtLeastOneValidValue = errors.some((v) => v.isValid());
    if (hasAtLeastOneValidValue) {
      this.success();
      return new ValidatorResult();
    }

    const result = errors.reduce(concat, new ValidatorResult());
    this.failure(result.errors());
    return result;
  };
}


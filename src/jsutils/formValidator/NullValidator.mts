import { Validator, IValidatorCallbacks } from "./Validator.mts";
import { ValidatorResult } from "./ValidatorResult.mts";

export class NullValidator extends Validator {
  private _not_null_message: string = "The value should be null";

  constructor(config: { message?: string } = {}) {
    super();
    if (config?.message) {
      this._not_null_message = config.message;
    }
  }

  on(config: IValidatorCallbacks = {}): NullValidator {
    this.registerCallbacks(config);
    return this;
  }

  override validate(value: unknown): ValidatorResult {
    const result = (value === null) ? [] : [this._not_null_message];
    return new ValidatorResult(result);
  }
}

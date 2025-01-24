import { areStrsEqual } from "../utils/common.mts";

import { Validator, IValidatorCallbacks } from "./Validator.mts";
import { ValidatorResult } from "./ValidatorResult.mts";
import { ValidatorsMap, concat, isPlainObject } from "./common.mts";

export class ObjectValidator extends Validator {
  private _scheme: ValidatorsMap = {};

  private _not_plain_object_message = "The value should be POJO";
  private _wrong_mapping_message = "The value can't be applied to scheme";

  constructor(
    value: ValidatorsMap = {},
    config: {
      pojoErrorMessage?: string;
      mappingErrorMessage?: string;
    } = {}
  ) {
    super();
    this._scheme = value;
    if (config?.pojoErrorMessage) {
      this._not_plain_object_message = config?.pojoErrorMessage;
    }
    if (config?.mappingErrorMessage) {
      this._wrong_mapping_message = config?.mappingErrorMessage;
    }
  }

  on(config: IValidatorCallbacks = {}): ObjectValidator {
    this.registerCallbacks(config);
    return this;
  }

  validate(mapping: unknown): ValidatorResult {
    this.reset();
    if (!isPlainObject(mapping)) {
      const errors = [this._not_plain_object_message];
      this.failure(errors);
      return new ValidatorResult(errors);
    }
    const ownedKeys = Object.keys(this._scheme).sort().join();
    const externalKeys = Object.keys(mapping).sort().join();
    if (!areStrsEqual(ownedKeys, externalKeys)) {
      const errors = [this._wrong_mapping_message];
      this.failure(errors);
      return new ValidatorResult(errors);
    }
    const result = Object.entries(this._scheme)
      .map(([key, validator]) => {
        const value = mapping[key];
        return validator.validate(value);
      })
      .reduce(concat, new ValidatorResult());
    if (result.isValid()) {
      this.success();
    } else {
      this.failure(result.errors());
    }
    return result;
  }
}

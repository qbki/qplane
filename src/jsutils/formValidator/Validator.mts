import { noop } from "../utils/common.mts"

import { ValidatorResult } from "./ValidatorResult.mts";

export interface IValidatorCallbacks {
  reset?: () => void;
  success?: () => void;
  failure?: (messages: Array<string>) => void;
}

export abstract class Validator {
  private _resetCb: () => void = noop;
  private _successCb: () => void = noop;
  private _failureCb: (message: Array<string>) => void = noop;

  abstract validate(value: unknown): ValidatorResult;

  protected reset() {
    this._resetCb();
  }

  protected success() {
    this._successCb();
  }

  protected failure(errors: Array<string>) {
    this._failureCb(errors);
  }

  protected registerCallbacks(config: IValidatorCallbacks): void {
    if (config.reset) this._resetCb = config.reset;
    if (config.success) this._successCb = config.success;
    if (config.failure) this._failureCb = config.failure;
  }
}

export class ValidatorResult {
  private _errors: Array<string> = [];

  constructor(errors: Array<string> = []) {
    this._errors = errors;
  }

  isValid(): boolean {
    return this._errors.length === 0;
  }

  errors(): Array<string> {
    return [...this._errors];
  }
}

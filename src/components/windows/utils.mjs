import { areStrsEqual } from "qrc:/jsutils/utils.mjs"
import { StringValidator } from "qrc:/jsutils/formValidator.mjs"

/**
 * @param {{ errorMessage: string }} input
 * @returns {import("../../jsutils/formValidator.mjs").IValidatorCallbacks}
 */
export function wrapInputErrors(input) {
  return {
    reset: function() { input.errorMessage = ""; },
    failure: function(errors) { input.errorMessage = errors.join("\n"); },
  };
}

/**
 * @param {Array<EntityBase>} list
 * @param {string} currentName
 * @returns {StringValidator}
 */
export function createNameValidator(list, currentName) {
  const uniqueNamesList = list
    .map(({ name }) => name)
    .filter((name) => !areStrsEqual(name, currentName));
  return new StringValidator()
    .notEmpty()
    .unique(uniqueNamesList);
}

/**
 * @returns {import("../../jsutils/formValidator.mjs").IValidatorCallbacks}
 */
export function createRootLogger() {
  return {
    failure: (errors) => console.warn(`Validation errors: ${errors.join("; ")}`),
  }
}

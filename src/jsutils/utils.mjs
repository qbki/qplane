export function partial(fn, ...args) {
  return function(...rest) {
    return fn(...args, ...rest);
  };
}

export function fireOnce(signal, fn) {
  const wrapper = function(...args) {
    fn(...args)
    signal.disconnect(wrapper);
  };
  signal.connect(wrapper);
}

export function noop() {
}

/**
 * Identity function
 */
export function id(value) {
  return value;
}

export function arity(fn, amount = 1) {
  return function(...args) {
    return fn(...args.slice(0, amount));
  }
}

export function reduceToObjectByField(fieldName) {
  return function(acc, value) {
    acc[value[fieldName]] = value;
    return acc;
  };
}

export function areStrsEqual(a, b) {
  return a.localeCompare(b) === 0;
}
export function partial(fn: any, ...args: any[]) {
  return function(...rest: any[]) {
    return fn(...args, ...rest);
  };
}

/**
 * Identity function
 */
export function id<T>(value: T): T {
  return value;
}

export function arity<T>(fn: (...args: unknown[]) => T, amount = 1) {
  return function(...args: unknown[]): T {
    return fn(...args.slice(0, amount));
  }
}

export function fireOnce(
  signal: QtSignal,
  fn: (...args: unknown[]) => void
): () => void {
  const wrapper = function(...args: unknown[]) {
    fn(...args)
    signal.disconnect(wrapper);
  };
  signal.connect(wrapper);
  return () => signal.disconnect(wrapper);
}

/**
 * @param item A leaf item in a tree
 * @param ctors Constructors
 * @returns Returns the first item in hierarchy that appears
 *          to be a derivative of any item in the ctors list
 */
export function findParentOf(
  item: { parent?: unknown },
  ctors: Array<new () => any> | (new () => any)
): { parent?: any } | null {
  const ctorsList = Array.isArray(ctors) ? ctors : [ctors];
  const isDerivative = ctorsList.some((ctor) => item instanceof ctor);
  if (isDerivative) {
    return item;
  }
  if (item.parent) {
    return findParentOf(item.parent, ctors);
  }
  return null;
}

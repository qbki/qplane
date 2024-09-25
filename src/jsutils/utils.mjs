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
  console.assert(typeof a === "string", "Expected a string");
  console.assert(typeof b === "string", "Expected a string");
  return a.localeCompare(b) === 0;
}

export function findParentOf(item, ctor) {
  if (item instanceof ctor) {
    return item;
  }
  if (item.parent) {
    return findParentOf(item.parent, ctor);
  }
  return null;
}


export function updateEntity(entitiesStore, newEntity, oldEntity) {
  const index = entitiesStore.findIndex((storedEntity) => storedEntity.id === oldEntity.id);
  if (index.valid) {
    entitiesStore.setData(index, newEntity);
  } else {
    console.error("Invalid index during an entity update");
  }
}

export function toFinitFloat(value, defaultValue = 0.0) {
  const result = Number.parseFloat(value);
  return Number.isFinite(result) ? result : defaultValue;
}

export function toFinitInt(value, defaultValue = 0) {
  const result = Number.parseInt(value);
  return Number.isFinite(result) ? result : defaultValue;
}

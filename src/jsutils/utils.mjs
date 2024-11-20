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
  return () => signal.disconnect(wrapper);
}

export function noop() {
}

/**
 * Identity function
 */
export function id(value) {
  return value;
}

export const uniqId = (function() {
  let counter = 0;
  return function() {
    counter += 1;
    return counter;
  };
})();

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

export function areFloatsEqual(a, b) {
  return Math.abs(a - b) < Number.EPSILON;
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

export function copy3dVector(vector) {
  return Qt.vector3d(vector.x, vector.y, vector.z);
}

export function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

export function valueOrDefault(value, defaultValue) {
  return (value === null || value === undefined) ? defaultValue : value;
}

export function isNil(value) {
  return value === null || value === undefined;
}

export function isNotNil(value) {
  return !isNil(value);
}

export function stringToValidNumber(value) {
  const num = Number.parseFloat(value);
  // Also: isFinite(NaN) returns false
  return Number.isFinite(num) ? num : 0;
}


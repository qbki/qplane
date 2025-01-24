pragma Singleton
import QtQuick

QtObject {
  /**
   * @param {string} module A module name ("QtQuick", etc)
   * @param {string} name A component name ("Text", etc)
   * @returns {((parent: null | QObject, props: object) => (T | null)) | never} Returns a component's instance factory function
   */
  function createComponent(module: string, name: string): var {
    const component = Qt.createComponent(module, name);
    switch (component.status) {
      case Component.Ready:
        return (parent, props) => {
          const instance = component.createObject(parent, props);
          if (!instance) {
            console.warn(`Instance of ${module}.${name} was not created, returned null`);
          }
          return instance;
        };
      case Component.Loading:
        throw new Error(`Please, prefer local components: ${module}.${name}`);
      case Component.Error:
        throw new Error(`Can't create component ${module}:${name}: ${component.errorString()}`);
      default:
        throw new Error(`Unknown error, can't create component ${module}:${name}`);
    }
  }
}

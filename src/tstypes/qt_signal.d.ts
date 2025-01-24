type QtSignalCallback = QtSignal | ((...args: unknown[]) => void);

interface QtSignal {
  connect(callback: QtSignalCallback): void;
  disconnect(callback: QtSignalCallback): void;
}

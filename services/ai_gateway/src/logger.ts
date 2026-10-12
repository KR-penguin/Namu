import type {SafeLogger, SafeRequestLog} from './ports.js';

export class JsonConsoleLogger implements SafeLogger {
  readonly #writeLine: (line: string) => void;

  constructor(
    writeLine: (line: string) => void = (line) => {
      process.stdout.write(`${line}\n`);
    },
  ) {
    this.#writeLine = writeLine;
  }

  write(entry: SafeRequestLog): void {
    // Rebuild the object instead of serializing the caller's value so an
    // accidental runtime property can never add content, tokens, or hashes.
    const safeEntry: SafeRequestLog = {
      event: 'request_complete',
      method: entry.method,
      route: entry.route,
      status: entry.status,
      latencyMs: entry.latencyMs,
      ...(entry.requestId === undefined ? {} : {requestId: entry.requestId}),
      ...(entry.operation === undefined ? {} : {operation: entry.operation}),
      ...(entry.idempotency === undefined
        ? {}
        : {idempotency: entry.idempotency}),
    };
    this.#writeLine(JSON.stringify(safeEntry));
  }
}

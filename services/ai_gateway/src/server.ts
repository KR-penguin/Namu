import {createServer, type Server} from 'node:http';
import {pathToFileURL} from 'node:url';

import {createGatewayHandler} from './app.js';
import {loadRuntimeConfig, type RuntimeConfig} from './config.js';
import {createRuntimeDependencies} from './runtime.js';

export async function startGateway(
  config: RuntimeConfig = loadRuntimeConfig(process.env),
): Promise<Server> {
  const server = createServer(
    createGatewayHandler(createRuntimeDependencies(config)),
  );
  await new Promise<void>((resolve, reject) => {
    const onError = (error: Error) => reject(error);
    server.once('error', onError);
    server.listen(config.port, '0.0.0.0', () => {
      server.off('error', onError);
      resolve();
    });
  });
  return server;
}

const entryPath = process.argv[1];
if (
  entryPath !== undefined &&
  import.meta.url === pathToFileURL(entryPath).href
) {
  void startGateway()
    .then((server) => {
      const close = () => {
        server.close(() => {
          process.exitCode = 0;
        });
      };
      process.once('SIGTERM', close);
      process.once('SIGINT', close);
    })
    .catch(() => {
      // Never print environment values, credentials, request bodies, or an SDK
      // error. This marker is sufficient for Cloud Run startup diagnostics.
      process.stderr.write('{"event":"startup_failed","status":1}\n');
      process.exitCode = 1;
    });
}

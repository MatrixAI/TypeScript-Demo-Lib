import { PolykeyAgent, PolykeyClient } from '@matrixai/polykey/src';
import { clientPB } from '@matrixai/polykey/src/client';
import { Metadata as Metadata2 } from '@matrixai/polykey/src/client/utils';
import Logger from '@matrixai/logger';
import { Metadata } from '@grpc/grpc-js';

const nodePath = 'tmp/keynode';

async function main() {
  const logger = new Logger();
  const agent = new PolykeyAgent({
    nodePath,
    logger
  });
  await agent.start({ password: 'password' });
  const client = new PolykeyClient({
    nodePath
  });
  await client.start({});
  try {
    const grpcClient = client.grpcClient;

    const echoMessage = new clientPB.EchoMessage();
    echoMessage.setChallenge('Hello!');
    console.log('First metadata');
    const meta = new Metadata();
    meta.add('First', 'Test');
    await grpcClient.echo(echoMessage, meta);

    //with other metadata.
    console.log('Second metadata')
    const meta2 = new Metadata2();
    meta2.add('Second', 'Test');
    await grpcClient.echo(echoMessage, meta2);

  } catch (e) {
    console.error(e);
  } finally {
    await client.stop();
    await agent.stop();
  }
}

main();

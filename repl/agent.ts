import { PolykeyAgent, PolykeyClient } from '@matrixai/polykey/dist';

const nodePath = 'tmp/keynode';

async function main() {
  const agent = new PolykeyAgent({
    nodePath
  });
  await agent.start({ password: 'password' });
}

main();

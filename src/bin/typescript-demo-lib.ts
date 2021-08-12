#!/usr/bin/env node

import process from 'process';
import Library from '../lib/Library';
import NumPair from '../lib/NumPair';
import { v4 as uuidv4 } from 'uuid';
import { PolykeyClient } from '@matrixai/polykey/dist';
import { clientPB } from '@matrixai/polykey/dist/client';
import { createMetadata } from "@matrixai/polykey/dist/client/utils";

async function main(argv = process.argv): Promise<number> {
  // Print out command-line arguments
  const argArray = argv.slice(2);
  const args = argArray.toString();
  process.stdout.write('[' + args + ']\n');

  // Create a new Library with the value someParam = 'new library'
  // And print it out
  const l = new Library('new library');
  process.stdout.write(l.someParam + '\n');

  // Generate and print a uuid (universally unique identifier)
  process.stdout.write(uuidv4() + '\n');

  // Add the first two command-line args and print the result
  const nums = new NumPair(parseInt(argArray[0]), parseInt(argArray[1]));
  const sum = nums.num1 + nums.num2;
  process.stdout.write(nums.num1 + ' + ' + nums.num2 + ' = ' + sum + '\n');

  //Lets do some grpc stuff here..
  const nodePath = 'tmp/keynode'
  const client = new PolykeyClient({nodePath})
  await client.start({});
  const grpcClient = client.grpcClient;
  const emptyMessage = new clientPB.EmptyMessage();
  const meta = createMetadata();
  meta.set('password', 'password');
  const res = await grpcClient.sessionRequestJWT(emptyMessage, meta);
  console.log(res.getToken());

  const echoMessage = new clientPB.EchoMessage();
  echoMessage.setChallenge('hello!');
  const res2 = await grpcClient.echo(echoMessage, meta);
  console.log(res2.getChallenge());

  process.exitCode = 0;
  return process.exitCode;
}

if (require.main === module) {
  main();
}

export default main;

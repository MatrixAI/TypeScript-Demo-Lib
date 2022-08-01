// // @ts-ignore windows
// process.stdout._handle.setBlocking(true);
// // @ts-ignore windows
// process.stderr._handle.setBlocking(true);

console.log('SETUP');

console.log(process.stdout.isTTY);
console.log(process.stderr.isTTY);

// @ts-ignore windows
console.log(process.stdout._handle);
// @ts-ignore windows
console.log(process.stderr._handle);

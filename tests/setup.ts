// @ts-ignore windows
process.stdout._handle.setBlocking(true);
// @ts-ignore windows
process.stderr._handle.setBlocking(true);

console.log(process.stdout.isTTY);
console.log(process.stderr.isTTY);

console.log(process.stdout._handle);
console.log(process.stderr._handle);

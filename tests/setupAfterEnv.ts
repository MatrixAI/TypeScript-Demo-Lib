console.log('SETUP AFTER ENV');
console.log(process.stdout.isTTY);
console.log(process.stderr.isTTY);
// @ts-ignore windows
console.log(process.stdout._handle);
// @ts-ignore windows
console.log(process.stderr._handle);

// Default timeout per test
// some tests may take longer in which case you should specify the timeout
// explicitly for each test by using the third parameter of test function
jest.setTimeout(global.defaultTimeout);

import path from 'path';
import process from 'process';
import level from 'level';

// Level tests.
async function testLevel(dir: string) {
  process.stdout.write('lets test some levelDB\n');
  const db = level(path.join(dir, 'levelDB'));
  const key = 'hello';
  const value = 'Level!';
  await db.put(key, value);
  process.stdout.write(key + ' ' + (await db.get(key)) + '\n');
  process.stdout.write('\n');
  await db.close();
}

export default testLevel;

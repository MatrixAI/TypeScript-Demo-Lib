const Sequencer = require('@jest/test-sequencer').default;

class CustomSequencer extends Sequencer {
  /**
   * Select tests for shard requested via --shard=shardIndex/shardCount
   * Sharding is applied before sorting
   */
  shard(tests, { shardIndex, shardCount }) {
    const shardSize = Math.ceil(tests.length / shardCount);
    const shardStart = shardSize * (shardIndex - 1);
    const shardEnd = shardSize * shardIndex;

    return [...tests]
      .sort((testA, testB) => {
        if (testA.duration && testB.duration) {
          return testA.duration > testB.duration ? 1 : -1;
        }
        return testA.path > testB.path ? 1 : -1;
      })
      .slice(shardStart, shardEnd);
  }
}

module.exports = CustomSequencer;

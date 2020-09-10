import { Library } from "@typescript-demo-lib/index";

describe('index', () => {

  let library: Library | null

  beforeAll(async done => {
    library = new Library('some param')
		done()
	})

	afterAll(() => {
		library = null
	})

  test('some arbitrary test', () => {
    expect(library?.someParam).toEqual('some param')
  });

});

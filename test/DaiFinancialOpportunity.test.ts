import chai, {expect} from 'chai'
import {createFixtureLoader, MockProvider, solidity} from 'ethereum-waffle'
import {encodePrice, expandTo18Decimals, expandToDecimals, mineBlock} from './shared/utilities'

const MINIMUM_LIQUIDITY = bigNumberify(10).pow(3)

chai.use(solidity)

const overrides = {
  gasLimit: 9999999,
}

describe('DaiFinancialOpportunity', () => {
  const provider = new MockProvider({
    hardfork: 'istanbul',
    mnemonic: 'horn horn horn horn horn horn horn horn horn horn horn horn',
    gasLimit: 9999999,
  })
  const [wallet, other] = provider.getWallets()
  const loadFixture = createFixtureLoader(provider, [wallet, other])

  beforeEach(async () => {
  }),

  it('deposit', async () => {
  }),

  it('redeem', async () => {

  }),
})
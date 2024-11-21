import { vars, HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
// import precompile tasks
import './tasks/validatorpool'

function getPrivKeys (): string[] {
  const strings: string[] = vars.get('MEZO_ACCOUNTS', '').split(',')
  const keys: string[] = []
  if (strings[0] !== '') {
    // Mezo accounts have been set already
    for (const str of strings) {
      if (str !== '') {
        keys.push(str)
      }
    }
  } else {
    console.log('MEZO_ACCOUNTS not set')
    return []
  }

  return keys
}

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.24',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      evmVersion: 'london'
    }
  },
  defaultNetwork: 'mezo_testnet',
  networks: {
    mezo_testnet: {
      url: 'https://rpc.test.mezo.org',
      chainId: 31611,
      accounts: getPrivKeys()
    }
  }
}

export default config

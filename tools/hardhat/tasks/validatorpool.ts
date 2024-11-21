import { task } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'

import abi from '../validatorPoolAbi.json'
const precompileAddress = '0x7b7c000000000000000000000000000000000011'

task('validatorPool:validators', 'Returns an array of operator addresses for current validators', async (taskArguments, hre) => {
  const validatorPool = new hre.ethers.Contract(precompileAddress, abi, hre.ethers.provider)
  const validators: string[] = await validatorPool.validators()
  console.log(validators)
})

task('validatorPool:validator', "Returns a validator's consensus public key & description")
  .addParam('operator', "The validator's operator address")
  .setAction(async (taskArguments, hre) => {
    const validatorPool = new hre.ethers.Contract(precompileAddress, abi, hre.ethers.provider)
    const validator = await validatorPool.validator(taskArguments.operator)
    console.log(validator)
  })

task('validatorPool:application', "Returns an application's consensus public key & description")
  .addParam('operator', "The application's operator address")
  .setAction(async (taskArguments, hre) => {
    const validatorPool = new hre.ethers.Contract(precompileAddress, abi, hre.ethers.provider)
    const application = await validatorPool.application(taskArguments.operator)
    console.log(application)
  })

task('validatorPool:applications', 'Returns an array of operator addresses for current applications', async (taskArguments, hre) => {
  const validatorPool = new hre.ethers.Contract(precompileAddress, abi, hre.ethers.provider)
  const candidates = await validatorPool.applications()
  console.log(candidates)
})

task('validatorPool:submitApplication', 'Submit a new validator application')
  .addParam('signer', 'The signer address (msg.sender)')
  .addParam('conspubkey', "The validator's consensus pub key")
  .addParam('moniker', "The validator's name")
  .addOptionalParam('identity', 'Optional identity signature (ex. UPort or Keybase)', '')
  .addOptionalParam('website', 'Optional website link', '')
  .addOptionalParam('security', 'Optional security contact information', '')
  .addOptionalParam('details', 'Optional details about the validator', '')
  .setAction(async (taskArguments, hre) => {
    const signer = await hre.ethers.getSigner(taskArguments.signer)
    const validatorPool = new hre.ethers.Contract(precompileAddress, abi, signer)
    const description: string[] = [
      taskArguments.moniker,
      taskArguments.identity,
      taskArguments.website,
      taskArguments.security,
      taskArguments.details
    ]
    const pending = await validatorPool.submitApplication(taskArguments.conspubkey, description)
    const confirmed = await pending.wait()
    console.log(confirmed.hash)
  })


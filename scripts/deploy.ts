import { getImplementationAddress } from "@openzeppelin/upgrades-core";
import { ethers, upgrades } from "hardhat";

const VAULT_FACTORY = "0xbD8D22F5e23d98054046dCb2bC27973D645ee02A";
const FEE_CONFIG = "0x6919950c9Ac8eb7b1e7831171286Bf05d779640A";

async function main() {
  try {
    const NATIVE = "0x039e2fB66102314Ce7b64Ce5Ce3E5183bc94aD38"; // Wrapped S on Sonic
    const DEV_ACCOUNT = "0x298Fb1BC4FdE509c781351F1047Fe659579feB91";
    const beefyFeeRecipient = DEV_ACCOUNT;
    const keeper = DEV_ACCOUNT;

    // // @note Vault factory
    // const BeefyVaultV7Factory = await ethers.getContractFactory("BeefyVaultV7Factory");
    // // BeefyVaultV7 instance will be deployed/created automatically if no address is provided
    // const vaultFactory = await BeefyVaultV7Factory.deploy(ethers.constants.AddressZero);
    // await vaultFactory.deployed();
    // console.log(
    //   `BeefyVaultV7Factory deployed to : ${vaultFactory.address}. Tx: ${vaultFactory.deployTransaction.hash}`
    // );

    // // @note Fee config (Upgradeable)
    // const [signer] = await ethers.getSigners();
    // const provider = signer.provider;

    // // Fees: call (gas refund), strategist, protocol ( uint256 beefy = DIVISOR - _call - _strategist;)
    // // divisor = 10_000
    // // 2%. WITHDRAWAL_FEE_CAP is set to 50 (0.05%/0.0005) in StratFeeManager
    // // withdrawalFee starts at 10 (0.001%)
    // const maxTotalFees = 200;

    // const BeefyFeeConfigurator = await ethers.getContractFactory("BeefyFeeConfigurator");
    // const beefyFeeConfig = await upgrades.deployProxy(BeefyFeeConfigurator, [keeper, maxTotalFees]);
    // await beefyFeeConfig.deployed();
    // // @ts-ignore
    // const _beefyFeeConfigImplementationAddr = await getImplementationAddress(provider, beefyFeeConfig.address);
    // console.log(
    //   `Deployed BeefyFeeConfigurator proxy at ${beefyFeeConfig.address}. Tx: ${beefyFeeConfig.deployTransaction.hash}`
    // );
    // console.log(`Deployed BeefyFeeConfigurator implementation at ${_beefyFeeConfigImplementationAddr}`);

    // // @note Strat factory
    // const StrategyFactory = await ethers.getContractFactory("StrategyFactory");
    // const stratFactory = await StrategyFactory.deploy(NATIVE, keeper, beefyFeeRecipient, FEE_CONFIG);
    // console.log(`StrategyFactory deployed to : ${stratFactory.address}. Tx: ${stratFactory.deployTransaction.hash}`);

    // @note StrategyFactoryCLM
    const StrategyFactoryCLM = await ethers.getContractFactory("StrategyFactoryCLM");
    const clmStratFactory = await StrategyFactoryCLM.deploy(NATIVE, keeper, beefyFeeRecipient, FEE_CONFIG);
    console.log(
      `StrategyFactoryCLM deployed to : ${clmStratFactory.address}. Tx: ${clmStratFactory.deployTransaction.hash}`
    );
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
}

main();

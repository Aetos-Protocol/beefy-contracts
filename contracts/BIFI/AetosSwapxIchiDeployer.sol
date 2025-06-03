// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./infra/StrategyFactory.sol";
import "./interfaces/beefy/IStrategyV7.sol";
import "./strategies/Ichi/StrategyIchi.sol";
import "./vaults/BeefyVaultV7Factory.sol";

import "@openzeppelin-5/contracts/token/ERC20/ERC20.sol";

contract AetosSwapxIchiDeployer {
    string public constant STRATEGY_NAME = "aetos-ichi-swapx-2";
    address public constant STRATEGIST = address(0xad1bB693975C16eC2cEEF65edD540BC735F8608B);
    address public constant FACTORY = address(0x9Df377a9c4FadFb1f7Bde79B92E31033D06a05A4);
    address public constant SWAPPER = address(0x46112C2618B57a4e03492E727957123E5097dF25);
    address public constant SWAPX_TOKEN = address(0xA04BC7140c26fc9BB1F36B1A604C7A5a88fb0E70);

    BeefyVaultV7Factory public vaultFactory = BeefyVaultV7Factory(address(0xffC494f0ED0C4d1ba5B830bcc8CbdC969b36A3Fc));
    StrategyFactory public strategyFactory = StrategyFactory(address(0x9Df377a9c4FadFb1f7Bde79B92E31033D06a05A4));

    event Deployed(string name, string symbol, address vault, address strategy);

    function deploy(
        string calldata name, 
        string calldata symbol, 
        address want, 
        address deposit, 
        address gauge, 
        uint256 amount
    ) public {
        BeefyVaultV7 vault = vaultFactory.cloneVault();
        StrategyIchi strategy = StrategyIchi(payable(strategyFactory.createStrategy(STRATEGY_NAME)));

        BaseAllToNativeFactoryStrat.Addresses memory addresses = BaseAllToNativeFactoryStrat.Addresses({
            strategist: STRATEGIST,
            factory: FACTORY,
            swapper: SWAPPER,
            depositToken: deposit,
            vault: address(vault),
            want: want
        });

        address[] memory rewards = new address[](1);
        rewards[0] = SWAPX_TOKEN;

        vault.initialize(IStrategyV7(address(strategy)), name, symbol, 0);
        strategy.initialize(gauge, false, rewards, addresses);

        IERC20(want).transferFrom(msg.sender, address(this), amount);
        IERC20(want).approve(address(vault), amount);

        vault.deposit(amount);

        uint256 vaultTokenBalance = IERC20(address(vault)).balanceOf(address(this));
        IERC20(address(vault)).transfer(msg.sender, vaultTokenBalance);

        emit Deployed(name, symbol, address(vault), address(strategy));
    }
}

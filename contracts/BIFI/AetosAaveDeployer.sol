// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import { StrategyFactory } from "./infra/StrategyFactory.sol";
import "./interfaces/beefy/IStrategyV7.sol";
import "./strategies/Aave/StrategyAaveSupplyOnly.sol";
import "./vaults/BeefyVaultV7Factory.sol";
import "./vaults/BeefyWrapper.sol";
import "./vaults/BeefyWrapperFactory.sol";

contract AetosAaveDeployer {
    string public constant STRATEGY_NAME = "aetos-aave-supply-2";
    address public constant NATIVE = address(0x039e2fB66102314Ce7b64Ce5Ce3E5183bc94aD38);
    address public constant REWARD = NATIVE;
    address public constant STRATEGIST = address(0xad1bB693975C16eC2cEEF65edD540BC735F8608B);
    address public constant SWAPPER = address(0x46112C2618B57a4e03492E727957123E5097dF25);
    address public constant KEEPER = address(0x2A86Ebd12573f4633453899156DA81345AC1d57D);
    address public constant FEE_RECIPIENT = STRATEGIST;
    address public constant FEE_CONFIGURATOR = address(0xB2983BC2FCBC44cC2dE16e7fE9b6c4242a820A82);
    address public constant OWNER = address(0xc4049acca995A4Ae3b7775dd46547494a96a1F53);

    BeefyVaultV7Factory public vaultFactory = BeefyVaultV7Factory(address(0x5d35CEE99eEF91f6F60cE8A0Fe4A746dFD6A5F06));
    StrategyFactory public strategyFactory = StrategyFactory(address(0x9Df377a9c4FadFb1f7Bde79B92E31033D06a05A4));

    event Deployed(string name, string symbol, address vault, address strategy, address wrapped);

    function deploy(
        string calldata name, 
        string calldata wrapped_name,
        string calldata symbol, 
        string calldata wrapped_symbol,
        address want, 
        address aToken, 
        address lendingPool, 
        address incentiveController,
        uint256 amount
    ) public {
        BeefyVaultV7 vault = vaultFactory.cloneVault();
        StrategyAaveSupplyOnly strategy = StrategyAaveSupplyOnly(payable(strategyFactory.createStrategy(STRATEGY_NAME)));

        StratFeeManagerInitializable.CommonAddresses memory addresses = StratFeeManagerInitializable.CommonAddresses({
            strategist: STRATEGIST,
            unirouter: SWAPPER,
            vault: address(vault),
            keeper: KEEPER,
            beefyFeeRecipient: FEE_RECIPIENT,
            beefyFeeConfig: FEE_CONFIGURATOR
        });

        vault.initialize(IStrategyV7(address(strategy)), name, symbol, 0);
        strategy.initialize(want, REWARD, NATIVE, aToken, lendingPool, incentiveController, addresses);
        strategy.setWithdrawalFee(0);
        _deposit(vault, want, amount);
        address wrapped = _wrap(wrapped_name, wrapped_symbol, vault);

        vault.transferOwnership(OWNER);
        strategy.transferOwnership(OWNER);

        emit Deployed(name, symbol, address(vault), address(strategy), wrapped);
    }

    function _deposit(BeefyVaultV7 vault, address want, uint256 amount) private  {
        IERC20(want).transferFrom(msg.sender, address(this), amount);
        IERC20(want).approve(address(vault), amount);

        vault.deposit(amount);

        uint256 vaultTokenBalance = IERC20(address(vault)).balanceOf(address(this));
        IERC20(address(vault)).transfer(msg.sender, vaultTokenBalance);
    }

    function _wrap(string calldata wrapped_name, string calldata wrapped_symbol, BeefyVaultV7 vault) private returns (address) {
        BeefyWrapper wrapper = new BeefyWrapper();
        wrapper.initialize(address(vault), wrapped_name, wrapped_symbol);
        return address(wrapper);
    }
}

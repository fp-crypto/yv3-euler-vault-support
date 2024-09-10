// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

import {AprOracleBase} from "@periphery/AprOracle/AprOracleBase.sol";
import {IEVault} from "@evk/EVault/IEVault.sol";
import {VaultLens, VaultInterestRateModelInfo} from "@evk-periphery/Lens/VaultLens.sol";

contract EulerVaultAprOracle is AprOracleBase {
    VaultLens public constant VAULT_LENS =
        VaultLens(0xE4044D26C879f58Acc97f27db04c1686fa9ED29E);

    constructor() AprOracleBase("Euler Vault Apr Oracle", msg.sender) {}

    /**
     * @notice Will return the expected APR of a Euler Vault post a supply change.
     * @param _eVault The euler vault to get the apr for.
     * @param _delta The difference in supply.
     * @return . The expected apr for the vault represented as 1e18.
     */
    function aprAfterDebtChange(
        address _eVault,
        int256 _delta
    ) external view override returns (uint256) {
        uint256[] memory _cash = new uint256[](1);
        _cash[0] = IEVault(_eVault).cash();
        require(int256(_cash[0]) >= -_delta, "delta too big"); // dev: _delta too big
        _cash[0] = uint256(int256(_cash[0]) + _delta);

        uint256[] memory _borrows = new uint256[](1);
        _borrows[0] = IEVault(_eVault).totalBorrows();

        VaultInterestRateModelInfo memory _info = VAULT_LENS
            .getVaultInterestRateModelInfo(_eVault, _cash, _borrows);

        return _info.interestRateInfo[0].supplyAPY / 1e9;
    }
}

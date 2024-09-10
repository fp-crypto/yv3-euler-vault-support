// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

import {AprOracleBase} from "@periphery/AprOracle/AprOracleBase.sol";
import {IEVault} from "@evk/EVault/IEVault.sol";
import {IIRM} from "@evk/InterestRateModels/IIRM.sol";
import {VaultLens, VaultInterestRateModelInfo} from "@evk-periphery/Lens/VaultLens.sol";

contract EulerVaultAprOracle is AprOracleBase {
    constructor() AprOracleBase("Strategy Apr Oracle Example", msg.sender) {}

    /**
     * @notice Will return the expected Apr of a strategy post a debt change.
     * @dev _delta is a signed integer so that it can also represent a debt
     * decrease.
     *
     * This should return the annual expected return at the current timestamp
     * represented as 1e18.
     *
     *      ie. 10% == 1e17
     *
     * _delta will be == 0 to get the current apr.
     *
     * This will potentially be called during non-view functions so gas
     * efficiency should be taken into account.
     *
     * @param _evault The euler vault to get the apr for.
     * @param _delta The difference in debt.
     * @return . The expected apr for the strategy represented as 1e18.
     */
    function aprAfterDebtChange(
        address _evault,
        int256 _delta
    ) external view override returns (uint256) {
        int256 _cash = int256(IEVault(_evault).cash());
        require(_cash >= -_delta, "delta too big"); // dev: _delta too big
        
        IIRM _irm = IIRM(IEVault(_evault).interestRateModel());
        return
            _irm.computeInterestRateView(
                _evault,
                uint256(_cash + _delta),
                IEVault(_evault).totalBorrows()
            );
    }
}

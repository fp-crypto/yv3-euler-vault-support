pragma solidity ^0.8.18;

import "forge-std/console.sol";
import {Setup} from "./utils/Setup.sol";

import {EulerVaultAprOracle} from "../periphery/EulerVaultAprOracle.sol";
import {IEVault} from "@evk/EVault/IEVault.sol"; 

contract OracleTest is Setup {
    EulerVaultAprOracle public oracle;

    function setUp() public override {
        super.setUp();
        oracle = new EulerVaultAprOracle();
    }

    function checkOracle(address _eulerVault, uint256 _delta) public {
        // Check set up
        // TODO: Add checks for the setup

        uint256 currentApr = oracle.aprAfterDebtChange(_eulerVault, 0);
        console.log("Current APR: %e", currentApr);

        // Should match the current apr of the euler vault
        assertEq(currentApr, IEVault(_eulerVault).interestRate(), "!match");

        if (IEVault(_eulerVault).cash() < _delta) {
            vm.expectRevert();
        }
        uint256 negativeDebtChangeApr = oracle.aprAfterDebtChange(_eulerVault, -int256(_delta));

        if (IEVault(_eulerVault).cash() > _delta) {
        // The apr should go up if deposits go down
        assertLt(currentApr, negativeDebtChangeApr, "negative change");
        }

        uint256 positiveDebtChangeApr = oracle.aprAfterDebtChange(_eulerVault, int256(_delta));

        assertGt(currentApr, positiveDebtChangeApr, "positive change");

   }

    function test_oracle(string memory _token, uint256 _amount, uint16 _percentChange) public {
        address _eulerVault = eulerBaseVaultAddrs[_token];
        vm.assume(_eulerVault != address(0));
        _amount = bound(_amount, minFuzzAmount, maxFuzzAmount);

        console.log("Euler Vault for %s", _token);

        _percentChange = uint16(bound(uint256(_percentChange), 10, MAX_BPS));
        uint256 _delta = (_amount * _percentChange) / MAX_BPS;
        checkOracle(_eulerVault, _delta);
    }

}

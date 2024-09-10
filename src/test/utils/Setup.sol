// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

import "forge-std/console2.sol";
import {ExtendedTest} from "./ExtendedTest.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Inherit the events so they can be checked if desired.
import {IEvents} from "@tokenized-strategy/interfaces/IEvents.sol";

interface IFactory {
    function governance() external view returns (address);

    function set_protocol_fee_bps(uint16) external;

    function set_protocol_fee_recipient(address) external;
}

contract Setup is ExtendedTest, IEvents {
    string[] public tokens = ["WETH", "USDT", "USDC"];
    mapping(string => address) public tokenAddrs;
    mapping(string => address) public eulerBaseVaultAddrs;

    // Addresses for different roles we will use repeatedly.
    address public user = address(10);
    address public keeper = address(4);
    address public management = address(1);

    // Integer variables that will be used repeatedly.
    uint256 public MAX_BPS = 10_000;

    // Fuzz from $0.01 of 1e6 stable coins up to 1 trillion of a 1e18 coin
    uint256 public maxFuzzAmount = 1e12;
    uint256 public minFuzzAmount = 1;

    function setUp() public virtual {
        _setTokenAddrs();
        _setEulerBaseAddrs();

        // label all the used addresses for traces
        vm.label(keeper, "keeper");
        vm.label(management, "management");
        for (uint8 i; i < tokens.length; ++i){
            vm.label(tokenAddrs[tokens[i]], tokens[i]);
            vm.label(tokenAddrs[tokens[i]], string(abi.encodePacked("e", tokens[i])));
        }
    }

    function airdrop(ERC20 _asset, address _to, uint256 _amount) public {
        uint256 balanceBefore = _asset.balanceOf(_to);
        deal(address(_asset), _to, balanceBefore + _amount);
    }

    function _setTokenAddrs() internal {
        tokenAddrs["WETH"] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        tokenAddrs["USDT"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        tokenAddrs["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    }

    function _setEulerBaseAddrs() internal {
        eulerBaseVaultAddrs["WETH"] = 0xD8b27CF359b7D15710a5BE299AF6e7Bf904984C2;
        eulerBaseVaultAddrs["USDT"] = 0x313603FA690301b0CaeEf8069c065862f9162162;
        eulerBaseVaultAddrs["USDC"] = 0x797DD80692c3b2dAdabCe8e30C07fDE5307D48a9;
    }

    function fixtureToken() public returns (string[] memory _tokensFixture) {
        _tokensFixture = new string[](tokens.length);
        for (uint8 i; i < tokens.length; ++i){
            _tokensFixture[i] = tokens[i];
        }
    }
}

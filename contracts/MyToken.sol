// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply * (10 ** decimals())); // Mint initial supply to deployer
    }

    function add100(uint someNumber) public view returns (uint) {
        return someNumber + 100;
    }
}

//0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512

/*
    mint
    burn
    stacking contract
        * stake 
        * unstake 
        * addRewards - 
*/

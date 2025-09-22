//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {ERC20} from "./token/ERC20.sol";



contract AkToken is ERC20{
    constructor(uint256 initialSupply,string memory _name,string memory _symbol) ERC20( _name, _symbol){
        _mint(msg.sender,initialSupply);
    }
}
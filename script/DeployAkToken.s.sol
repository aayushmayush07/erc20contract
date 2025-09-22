//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;


import {Script} from "forge-std/Script.sol";
import {AkToken} from "../src/AkToken.sol";


contract DeployAkToken is Script{
    uint256 public constant INITIAL_SUPPLY=1000 ether;
    string public constant NAME="AKToken";
    string public constant SYMBOL="AKT";


    function run() external returns(AkToken){
        vm.startBroadcast(address(this));
        AkToken akt=new AkToken(INITIAL_SUPPLY,NAME,SYMBOL);
        vm.stopBroadcast();


        return akt;

    }
}
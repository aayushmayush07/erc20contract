//SPDX-License-Identifier:MIT

/**
 * @dev This is an interface for ERC20 token as defined in the ERC
 */

pragma solidity >=0.4.16;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);


    function approve(address spender,uint256 value) external returns(bool);


    function transferFrom(address from,address to, uint256 value) external returns(bool);
}

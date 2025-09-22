//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployAkToken} from "../script/DeployAkToken.s.sol";
import {ERC20Harness} from "./mocks/ERC20MintMock.sol";
import {AkToken} from "../src/AkToken.sol";
import {IERC20Errors} from "../src/interface/IERC20Errors.sol";
event Transfer(address indexed from, address indexed to, uint value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
contract AkTokenTest is Test {
    AkToken public akToken;
    DeployAkToken public deployer;
    uint256 public constant STARTING_BALANCE = 100 ether;
        uint256 public constant INITIAL_SUPPLY=1000 ether;
    string public constant NAME="AKToken";
    string public constant SYMBOL="AKT";

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address hazel = makeAddr("hazel");

    function setUp() public {
        deployer = new DeployAkToken();
        akToken = deployer.run();

        vm.prank(address(deployer));
        akToken.transfer(bob, STARTING_BALANCE);
    }

    function testShowAkTokenAddress() public view {
        console.log("akToken address:", address(akToken));
    }

    function testShowDeployTokenAddress() public view {
        console.log("deploy address address:", address(deployer));
    }

    function testShowTestContractAddress() public view {
        console.log("test address:", address(msg.sender));
    }

    function testBalanceOfOwnerAddress() public view {
        console.log(
            "balance at address owner of token",
            akToken.balanceOf(address(deployer))
        );
    }

    function testStartingArgumentsToConstructor() public view {
        assertEq(akToken.totalSupply(), deployer.INITIAL_SUPPLY());
        assertEq(akToken.name(), deployer.NAME());
        assertEq(akToken.symbol(), deployer.SYMBOL());
        assertEq(akToken.decimals(), 18);
    }

    function testBalanceOfBob() public view {
        assertEq(akToken.balanceOf(address(bob)), 100 ether);
    }

    function testAllowance() public {
        assertEq(akToken.allowance(address(deployer), address(bob)), 0);

        vm.expectEmit(true,true,false,true);
        emit Approval(bob,alice,10 ether);
        vm.prank(bob);

        bool ok=akToken.approve(address(alice), 10 ether);
        assertTrue(ok, "approve should return true");

        assertEq(akToken.allowance(address(bob), address(alice)), 10 ether);
        
        vm.expectEmit(true,true,false,true);
        emit Transfer(address(bob),address(hazel),1 ether);

        vm.prank(alice);
        
        akToken.transferFrom(address(bob), address(hazel), 1 ether);

        assertEq(akToken.allowance(address(bob), address(alice)), 9 ether);
        assertEq(akToken.allowance(address(hazel), address(deployer)), 0 ether);
    }

    function testAllowanceRevertsOnTryingToSpendMoreThanAllowed() public {
        assertEq(akToken.allowance(address(deployer), address(bob)), 0);
        vm.prank(bob);
        akToken.approve(address(alice), 10 ether);

vm.expectRevert(
    abi.encodeWithSelector(
        IERC20Errors.ERC20InsufficientAllowance.selector,
        alice,
        10 ether,
        11 ether
    )
);
        vm.prank(alice);
        akToken.transferFrom(address(bob), address(hazel), 11 ether);
    }

    function testAllowanceRevertsOnTryingToSpendMoreUINT256Max() public {
        assertEq(akToken.allowance(address(deployer), address(bob)), 0);
        vm.prank(bob);
        akToken.approve(address(alice), 10 ether);

        vm.expectRevert();
        vm.prank(alice);
        akToken.transferFrom(address(bob), address(hazel),type(uint256).max);
    }

    function testTransferToSelf() public{

        uint256 prevBobBalance=akToken.balanceOf(address(bob));
        vm.expectEmit(true,true,false,true);
        emit Transfer(bob, bob, 10 ether); 
        vm.prank(bob);
        akToken.transfer(bob,10 ether);


        assertEq(akToken.balanceOf(address(bob)),prevBobBalance);



    }

    function testZeroAddressRevert() public{
        vm.expectRevert();
        vm.prank(address(0));
        akToken.transfer(address(bob),1 ether);


        vm.expectRevert();
        vm.prank(bob);
        akToken.transfer(address(0),10 ether);
        


    }

    function testRevertOnInsufficientBalance() public {
    // bob only has 100 ether from setUp
    uint256 bobBalance = akToken.balanceOf(bob);
    vm.expectRevert();
    vm.prank(bob);
    akToken.transfer(alice, bobBalance + 1 ether);
}

    function testRevertOnInsufficientAllowance() public {
    // bob approves alice for 1 ether
    vm.prank(bob);
    akToken.approve(alice, 1 ether);

    vm.expectRevert();
    vm.prank(alice);
    akToken.transferFrom(bob, hazel, 2 ether);
}

function testRevertOnApproveZeroSpender() public {
    vm.expectRevert(

    );
    vm.prank(bob);
    akToken.approve(address(0), 1 ether);
}
function testFuzz_SupplyConservation(uint256 amount1, uint256 amount2, uint256 amount3) public{
    vm.prank(address(deployer));
    akToken.transfer(bob,50 ether);
    vm.prank(address(deployer));
    akToken.transfer(alice,25 ether);
    vm.prank(address(deployer));
    akToken.transfer(hazel,25 ether);



    address[3] memory users=[bob,alice,hazel];
    address sender=users[amount1%3];
    address receiver= users[amount2%3];
    uint256 value=amount3 % (akToken.balanceOf(sender)+1);


    vm.prank(sender);
    akToken.transfer(receiver,value);



    uint256 total;

    for(uint256 i=0;i<users.length;i++){
        total+=akToken.balanceOf(users[i]);
    }


    total+=akToken.balanceOf(address(deployer));

    assertEq(total,akToken.totalSupply(),"Supply not conserved");
}

function testFuzzTransferAlgebraConsistent(uint256 amount) public{
    uint256 balanceOfBob=akToken.balanceOf(bob);
    uint256 balanceOfHazel=akToken.balanceOf(hazel);
    uint x= amount%balanceOfBob;
    vm.prank(bob);
    akToken.transfer(hazel,x);


    uint256 afterBalanceOfBob=akToken.balanceOf(bob);
    uint256 afterBalanceOfHazel=akToken.balanceOf(hazel);


    assertEq(balanceOfBob-x,afterBalanceOfBob);
    assertEq(balanceOfHazel+x,afterBalanceOfHazel);




}

function testFuzz_AllowanceAlgebra(uint96 approveAmount, uint96 spendAmount) public {
    // 1. Bound fuzzed values
vm.assume(approveAmount > 0);
vm.assume(spendAmount > 0);
vm.assume(spendAmount <= approveAmount);
vm.assume(spendAmount <= akToken.balanceOf(bob));


    // 2. Fund Bob so he can actually spend
    vm.prank(address(deployer));
    akToken.transfer(bob, 1_00 ether);

    // 3. Approve Alice
    vm.prank(bob);
    akToken.approve(alice, approveAmount);

    // 4. Alice spends `spendAmount`
    vm.prank(alice);
    akToken.transferFrom(bob, hazel, spendAmount);

    // 5. Assert algebra
    assertEq(
        akToken.allowance(bob, alice),
        approveAmount - spendAmount,
        "allowance not reduced correctly"
    );
}

function testMintEmitsTransfer() public {
    ERC20Harness harness=new ERC20Harness(INITIAL_SUPPLY,NAME,SYMBOL);
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(0), bob, 50 ether);

    harness.exposedMint(bob, 50 ether);

    assertEq(harness.balanceOf(bob), 50 ether);
    assertEq(harness.totalSupply(), deployer.INITIAL_SUPPLY() + 50 ether);
}
function testMintToZeroAddressReverts() public {
    ERC20Harness harness = new ERC20Harness(INITIAL_SUPPLY, NAME, SYMBOL);

    vm.expectRevert(
        abi.encodeWithSelector(
            IERC20Errors.ERC20InvalidReceiver.selector,
            address(0)
        )
    );

    harness.exposedMint(address(0), 50 ether);
}
function testBurnFromZeroAddressReverts() public {
    ERC20Harness harness = new ERC20Harness(INITIAL_SUPPLY, NAME, SYMBOL);

    vm.expectRevert(
        abi.encodeWithSelector(
            IERC20Errors.ERC20InvalidSender.selector,
            address(0)
        )
    );

    harness.exposedBurn(address(0), 10 ether);
}


function testBurnEmitsTransfer() public {
    ERC20Harness harness=new ERC20Harness(INITIAL_SUPPLY,NAME,SYMBOL);
    // First give Bob some tokens
    harness.exposedMint(bob, 20 ether);

    vm.expectEmit(true, true, false, true);
    emit Transfer(bob, address(0), 20 ether);

    harness.exposedBurn(bob, 20 ether);

    assertEq(harness.balanceOf(bob), 0);
    assertEq(harness.totalSupply(), deployer.INITIAL_SUPPLY());
}


function testApproveZeroSpenderReverts() public {
    vm.expectRevert(
        abi.encodeWithSelector(
            IERC20Errors.ERC20InvalidSpender.selector,
            address(0)
        )
    );
    vm.prank(bob);
    akToken.approve(address(0), 1 ether);
}

function testApproveZeroOwnerReverts() public {
    ERC20Harness harness = new ERC20Harness(INITIAL_SUPPLY, NAME, SYMBOL);

    vm.expectRevert(
        abi.encodeWithSelector(
            IERC20Errors.ERC20InvalidApprover.selector,
            address(0)
        )
    );

    harness.exposedApprove(address(0), alice, 1 ether);
}

}

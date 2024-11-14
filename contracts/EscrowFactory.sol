// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Escrow.sol";  // Assuming Escrow contract is in the same directory

contract EscrowFactory {
    address public owner;
    address public cUSDAddress;

    mapping(address => address[]) public escrowsByPayer;
    mapping(address => address[]) public escrowsByPayee;

    event EscrowCreated(address escrowContract, address owner);

    constructor(address _cUSDAddress) {
        owner = msg.sender;
        cUSDAddress = _cUSDAddress;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // Create an escrow contract for a trade
    function createEscrow(
        address _payee, 
        address _escrowAgent, 
        uint256 _releasePercentage
    ) external returns (address) {
        // Deploy a new Escrow contract
        Escrow newEscrow = new Escrow(_payee, _escrowAgent, _releasePercentage, cUSDAddress);
        
        // Transfer ownership of the escrow contract to the caller
        newEscrow.transferOwnership(msg.sender);

        // Track the new escrow contract
        escrowsByPayer[msg.sender].push(address(newEscrow));
        escrowsByPayee[_payee].push(address(newEscrow));

        emit EscrowCreated(address(newEscrow), msg.sender);

        return address(newEscrow);
    }

    // Optionally add more helper functions to view escrows by payer/payee or interact with them
}

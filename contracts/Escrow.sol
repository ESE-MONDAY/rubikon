// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Escrow {
    address public payer;           // The person who deposits funds into escrow
    address public payee;           // The recipient of the funds after release
    address public escrowAgent;     // Optional third party for oversight
    address public owner;           // The owner of the escrow contract (the one who created it)
    IERC20 public cUSD;             // The cUSD token contract
    uint256 public totalAmount;     // Total amount deposited in escrow (in cUSD)
    uint256 public releasedAmount;  // Amount already released
    uint256 public releasePercentage; // The release percentage per trigger (in basis points, e.g., 10000 = 100%)
    bool public isRefunded;         // Flag for refund status
    bool public isCompleted;        // Flag for escrow completion

    event FundDeposited(address payer, uint256 amount);
    event FundReleased(address payee, uint256 amount);
    event FundRefunded(address payer, uint256 amount);
    event EscrowCompleted();
    event OwnershipTransferred(address previousOwner, address newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier onlyPayer() {
        require(msg.sender == payer, "Only payer can call this");
        _;
    }

    modifier onlyEscrowAgent() {
        require(msg.sender == escrowAgent, "Only escrow agent can call this");
        _;
    }

    modifier notRefunded() {
        require(!isRefunded, "Refund has already been processed");
        _;
    }

    modifier notCompleted() {
        require(!isCompleted, "Escrow is already completed");
        _;
    }

    constructor(
        address _payee, 
        address _escrowAgent, 
        uint256 _releasePercentage, 
        address _cUSDAddress
    ) {
        payer = msg.sender;  // The one who deploys this contract is the payer
        payee = _payee;
        escrowAgent = _escrowAgent;
        releasePercentage = _releasePercentage;
        cUSD = IERC20(_cUSDAddress);  // Set the cUSD contract address
        owner = msg.sender; // The creator (deployer) is the owner initially
        isRefunded = false;
        isCompleted = false;
    }

    // Transfer ownership of the contract to a new address
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Deposit function to send cUSD into the escrow
    function deposit(uint256 amount) external onlyPayer {
        require(amount > 0, "Amount must be greater than 0");
        require(totalAmount == 0, "Funds are already deposited");

        // Transfer cUSD from payer to this contract
        require(cUSD.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        totalAmount = amount;
        emit FundDeposited(msg.sender, amount);
    }

    // Function to release a percentage of the funds to the payee
    function release() external notRefunded notCompleted onlyOwner {
        uint256 releaseAmount = (totalAmount * releasePercentage) / 10000;  // percentage in basis points
        require(releaseAmount + releasedAmount <= totalAmount, "Cannot release more than the total amount");

        releasedAmount += releaseAmount;

        // Transfer the release amount in cUSD to the payee
        require(cUSD.transfer(payee, releaseAmount), "Transfer failed");
        emit FundReleased(payee, releaseAmount);
    }

    // Function to trigger a total refund if necessary
    function refund() external onlyPayer notRefunded notCompleted {
        isRefunded = true;
        uint256 refundAmount = totalAmount - releasedAmount;

        // Transfer the refund amount back to the payer in cUSD
        require(cUSD.transfer(payer, refundAmount), "Refund transfer failed");
        emit FundRefunded(payer, refundAmount);
    }

    // Mark the escrow as completed (when no further releases or refunds are required)
    function completeEscrow() external onlyEscrowAgent {
        isCompleted = true;
        emit EscrowCompleted();
    }

    // Helper functions to check the status
    function getEscrowBalance() external view returns (uint256) {
        return totalAmount - releasedAmount;
    }

    function isEscrowCompleted() external view returns (bool) {
        return isCompleted;
    }
}

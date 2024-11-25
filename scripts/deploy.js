const hre = require("hardhat");

async function main() {
  try {
    // Get signers (the deployer of the contract)
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Get the contract factory for EscrowFactory
    const EscrowFactory = await hre.ethers.getContractFactory("EscrowFactory");

    // Parameters for deploying the factory
    const cUSDAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"; // Alfajores cUSD address

    // Deploy the EscrowFactory contract
    console.log("Deploying EscrowFactory...");
    const escrowFactory = await EscrowFactory.deploy(cUSDAddress);

    // Wait for the deployment to complete
    await escrowFactory.waitForDeployment();

    // Access the contract address from the 'target' property
    console.log("EscrowFactory deployed to:", escrowFactory.target);  // Fix here: Use escrowFactory.target



    const payee = "0x1657c513C2cC90e4C4e49c7c60122BCBe146D727";  // Replace with actual payee address
    const escrowAgent = "0x5FbDB2315678afecb367f032d93F642f64180aa3";  // Replace with actual escrow agent address
    const releasePercentage = 25000;


    console.log("Creating an Escrow contract through the factory...");
    const tx = await escrowFactory.createEscrow(payee, escrowAgent, releasePercentage);


    // Wait for the transaction to be mined
    const receipt = await tx.wait();
    console.log("Transaction receipt:", receipt);


    const escrowCreatedEvent = receipt.events?.find(event => event.event === "EscrowCreated");

    if (!escrowCreatedEvent) {
      console.error("EscrowCreated event not found in transaction receipt.");
      return;
    }


    const escrowAddress = escrowCreatedEvent.args.escrowContract;
    console.log("Escrow contract created at:", escrowAddress);


    const escrowContract = await hre.ethers.getContractAt("Escrow", escrowAddress);
    console.log("Escrow Contract Parameters:");
    console.log("Payee:", await escrowContract.payee());
    console.log("Escrow Agent:", await escrowContract.escrowAgent());
    console.log("Release Percentage:", await escrowContract.releasePercentage());
    console.log("cUSD Address:", await escrowContract.cUSD());


  } catch (error) {
    console.error("Error during deployment:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

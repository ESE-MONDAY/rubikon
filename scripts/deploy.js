const hre = require("hardhat");

async function main() {
  try {
    // Get signers (the deployer of the contract)
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Get the contract factory for EscrowFactory (not the individual Escrow contract)
    const EscrowFactory = await hre.ethers.getContractFactory("EscrowFactory");

    // Parameters for deploying the factory
    const cUSDAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"; // Alfajores cUSD address

    // Deploy the EscrowFactory contract
    console.log("Deploying EscrowFactory...");
    const escrowFactory = await EscrowFactory.deploy(cUSDAddress);
    await escrowFactory.waitForDeployment();
    console.log("EscrowFactory deployed to:", escrowFactory.address);

    // Optionally deploy an Escrow contract using the factory
    const payee = "0x1657c513C2cC90e4C4e49c7c60122BCBe146D727";  // Replace with actual payee address
    const escrowAgent = "0x5FbDB2315678afecb367f032d93F642f64180aa3";  // Replace with actual escrow agent address
    const releasePercentage = 25000; // Release percentage (in basis points, 25000 = 25%)

    // Call the factory to create an Escrow contract
    // console.log("Creating an Escrow contract through the factory...");
    // const tx = await escrowFactory.createEscrow(payee, escrowAgent, releasePercentage);
    // const receipt = await tx.wait();

    // // Check if the event was emitted
    // const escrowCreatedEvent = receipt.events?.find(event => event.event === "EscrowCreated");

    // if (!escrowCreatedEvent) {
    //   console.error("EscrowCreated event not found in transaction receipt.");
    //   return;
    // }

    // Get the address of the created Escrow contract from the event
    // const escrowAddress = escrowCreatedEvent.args.escrowContract;
    // console.log("Escrow contract created at:", escrowAddress);

    // // Optionally log contract parameters
    // const escrowContract = await hre.ethers.getContractAt("Escrow", escrowAddress);
    // console.log("Escrow Contract Parameters:");
    // console.log("Payee:", await escrowContract.payee());
    // console.log("Escrow Agent:", await escrowContract.escrowAgent());
    // console.log("Release Percentage:", await escrowContract.releasePercentage());
    // console.log("cUSD Address:", await escrowContract.cUSD());

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

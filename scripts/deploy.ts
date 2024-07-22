import hre from "hardhat"

const main = async()=>{
    const myContract = await hre.ethers.getContractFactory('PayWeb3');
    const contract = await myContract.deploy();
    console.log("deployed address: ", contract.target);
    return contract.target;
}

main().then((res: any)=>{
    console.log("contract has been deployed!", res);
}).catch((err: Error) => {
    console.log(err);
})

// npx hardhat run scripts/deploy.ts --network mumbai 
// contract address at polygon chain (chainId - 80002) 0x62c8586604B73F206449c7E951b2EbFc169738C2
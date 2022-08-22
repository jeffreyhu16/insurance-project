import { deployments, ethers, getNamedAccounts, network } from "hardhat";
import { developmentChains } from "../../helper-hardhat-config";
import { Distribution } from "../../typechain-types";

if (developmentChains.includes(network.name)) {
    describe('Distribution Unit Test', () => {
        const { utils: { parseEther }, constants } = ethers;
        let deployer: string, distribution: Distribution;

        beforeEach(async () => {
            deployer = (await getNamedAccounts()).deployer;
            await deployments.fixture(['all']);
            distribution = await ethers.getContract('Distribution');
        });
    });
} else {    
    describe.skip;
}
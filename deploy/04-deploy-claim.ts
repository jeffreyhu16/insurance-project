import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { developmentChains } from "../helper-hardhat-config";
import verify from "../utils/verify";

const deployClaim: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    // @ts-ignore
    const { deployments: { deploy, log, all }, getNamedAccounts } = hre;
    const { deployer } = await getNamedAccounts();
    const { Cover, Pool, Governance } = await all();

    const claim = await deploy('Claim', {
        from: deployer,
        log: true,
        args: [Cover.address, Pool.address],
    });

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(claim.address, []);
    }
}

export default deployClaim;
deployClaim.tags = ['all', 'claim'];
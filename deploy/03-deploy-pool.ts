import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { developmentChains } from "../helper-hardhat-config";
import verify from "../utils/verify";

const deployPool: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    // @ts-ignore
    const { deployments: { deploy, log, get }, getNamedAccounts } = hre;
    const { deployer } = await getNamedAccounts();

    const pool = await deploy('Pool', {
        from: deployer,
        log: true,
        args: [],
    });

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(pool.address, []);
    }
}

export default deployPool;
deployPool.tags = ['all', 'pool'];
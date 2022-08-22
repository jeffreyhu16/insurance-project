import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { developmentChains } from "../helper-hardhat-config";
import verify from "../utils/verify";

const deployCover: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    // @ts-ignore
    const { deployments: { deploy, log, get }, getNamedAccounts, getChainId } = hre;
    const { deployer } = await getNamedAccounts();
    const chainId = await getChainId();

    const cover = await deploy('Cover', {
        from: deployer,
        log: true,
        args: [],
    });

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(cover.address, []);
    }
}

export default deployCover;
deployCover.tags = ['all', 'cover'];
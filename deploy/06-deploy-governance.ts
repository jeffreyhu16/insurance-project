import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { developmentChains } from "../helper-hardhat-config";
import verify from "../utils/verify";

const deployGovernance: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    // @ts-ignore
    const { deployments: { deploy, log, get }, getNamedAccounts } = hre;
    const { deployer } = await getNamedAccounts();
    const distribution = await get('Distribution');

    const governance = await deploy('Governance', {
        from: deployer,
        log: true,
        args: [
            distribution.address,
            1,
            45818,
            4
        ],
    });

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(governance.address, []);
    }
}

export default deployGovernance;
deployGovernance.tags = ['all', 'governance'];
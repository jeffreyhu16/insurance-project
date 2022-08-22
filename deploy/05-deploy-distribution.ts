import { network } from 'hardhat';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { developmentChains } from '../helper-hardhat-config';
import verify from '../utils/verify';

const distributionDeploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    // @ts-ignore
    const { deployments: { deploy, all }, getNamedAccounts } = hre;
    const { deployer } = await getNamedAccounts();
    const { Cover, Claim, Quote, Pool, Governance } = await all();
    
    const distribution = await deploy('Distribution', {
        from: deployer,
        log: true,
        args: [
            Cover.address,
            Claim.address,
            Quote.address,
            Pool.address
        ]
    });

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(distribution.address, []);
    }
}

export default distributionDeploy;
distributionDeploy.tags = ['all', 'distribution'];

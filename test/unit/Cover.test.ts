import { getNamedAccounts, deployments, ethers, network } from 'hardhat';
import { developmentChains } from '../../helper-hardhat-config';
import { Cover } from '../../typechain-types';
import { assert, expect } from 'chai';
import { ContractTransaction, ethers as Ethers } from 'ethers';

if (developmentChains.includes(network.name)) {
    describe('Cover Unit Test', () => {
        const { utils: { parseEther }, constants } = ethers;
        let deployer: string, cover: Cover, coverId: number;

        type BigNumber = Ethers.BigNumber;
        let addCoverArgs: [string, string, string, BigNumber, BigNumber, number, BigNumber];
        let addCoverTx: ContractTransaction;

        beforeEach(async () => {
            await deployments.fixture(['all']);
            const distribution = await deployments.get('Distribution');
            cover = await ethers.getContract('Cover');

            const tx = await cover.setDistribution(distribution.address);
            await tx.wait(1);

            const fundSource = (await ethers.getSigners())[0];
            await fundSource.sendTransaction({
                to: distribution.address,
                value: parseEther('1')
            });
            await network.provider.send('hardhat_impersonateAccount', [distribution.address]);
            const distributionSigner = await ethers.getSigner(distribution.address);
            addCoverArgs = [
                constants.AddressZero,  
                constants.AddressZero,
                'ETH',
                parseEther('1'),
                parseEther('0.01'),
                31556926,
                ethers.BigNumber.from('1657013408')
            ];
            addCoverTx = await cover.connect(distributionSigner).addCover(...addCoverArgs);
            const txReceipt = await addCoverTx.wait(1);
            coverId = txReceipt.events![0].args!.coverId;
        });

        describe('addCover', () => {
            it('reverts if caller isnt distribution', async () => {
                await expect(cover.addCover(...addCoverArgs))
                    .to.be.revertedWith('Distributable__NotDistributionCaller');
            });
            it('increments coverId counter', async () => {
                assert.equal(coverId.toString(), '1');
            });
            it('adds new cover to mapping correctly', async () => {
                const newCover = await cover.covers(1);
                for (let i = 0; i < addCoverArgs.length; i++) {
                    assert.equal(addCoverArgs[i].toString(), newCover[i].toString());
                }
                assert.equal(newCover.status, 0);
            });
            it('emits CoverPurchased event with correct args', async () => {
                await expect(addCoverTx)
                    .to.emit(cover, 'CoverPurchased')
                    .withArgs('1', constants.AddressZero, parseEther('0.01').toString());
            });
        });

        describe('getCoverStatus', () => {
            it('gets the requested cover status correctly', async () => {
                const status = await cover.getCoverStatus(1);
                assert.equal(status, 0);
            });
        });
    });
} else {
    describe.skip;
}

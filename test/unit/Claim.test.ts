import { ContractTransaction, ethers as Ethers } from "ethers";
import { deployments, ethers, getNamedAccounts, network } from "hardhat";
import { Claim } from "../../typechain-types";
import { developmentChains } from '../../helper-hardhat-config';
import { assert } from "chai";

if (developmentChains.includes(network.name)) {
    describe('Claim Unit Test', () => {
        const { utils: { parseEther } } = ethers;
        let deployer: string, claim: Claim, claimId: number;
        let addClaimTx: ContractTransaction;
        type BigNumber = Ethers.BigNumber;
        let addClaimArgs: [string, BigNumber, string, BigNumber];

        beforeEach(async () => {
            deployer = (await getNamedAccounts()).deployer;
            await deployments.fixture(['all']);
            claim = await ethers.getContract('Claim');
            
        });

        describe('claim constructor', () => {
            it('sets contract addresses correctly', async () => {
                const { Cover, Pool } = await deployments.all();
                assert.equal(await claim.cover(), Cover.address);
                assert.equal(await claim.pool(), Pool.address);
            });
        });

        describe('setGovernance', () => {
            it('sets address correctly', async () => {
                const tx = await claim.setGovernance(ethers.constants.AddressZero);
                await tx.wait(1);
                assert.equal(await claim.gov(), ethers.constants.AddressZero);
            });
        });

        describe('addClaim', () => {
            beforeEach(async () => {
                // use governance to approve protocol in order for claim to succeed
                addClaimArgs = [
                    ethers.constants.AddressZero,
                    ethers.BigNumber.from('1'),
                    ethers.constants.AddressZero,
                    parseEther('1')
                ];
                addClaimTx = await claim.addClaim(...addClaimArgs);
                const txReceipt = await addClaimTx.wait(1);
                claimId = txReceipt.events![0].args!.claimId;
            });
            it('reverts if protocol has not been approved by governance', async () => {

            });
            it('increments claimId counter', async () => {

            });
            it('adds new claim to mapping correctly', async () => {

            });
            it('emits ClaimCreated event with correct args', async () => {

            });
        });

        describe('redeemClaim', () => {

        });
    });
} else {
    describe.skip;
}

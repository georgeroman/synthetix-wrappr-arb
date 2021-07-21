import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract, utils } from "ethers";
import { ethers } from "hardhat";

import { deployContract } from "../src/utils";

describe("EtherWrapprArb", function () {
  this.timeout(600000);

  let deployer: SignerWithAddress;
  let arber: SignerWithAddress;

  let weth: Contract;

  before(async () => {
    [deployer, arber] = await ethers.getSigners();

    weth = await ethers.getContractAt(
      "IERC20",
      "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    );
  });

  const testArb = (contractName: string) => {
    describe(contractName, () => {
      let contract: Contract;

      before(async () => {
        contract = await deployContract({
          name: contractName,
          from: deployer,
          args: [arber.address],
        });
      });

      const arb = async (amount: number) => {
        await contract.connect(arber).trigger(utils.parseEther(`${amount}`));
      };

      const claim = async () => {
        await contract.connect(arber).claim();
      };

      const amounts = [1, 5, 10, 25, 50, 100, 200, 500];
      for (const amount of amounts) {
        it(`arb ${amount} WETH`, async () => {
          const amountBefore = await weth.balanceOf(arber.address);
          await arb(amount);
          await claim();
          const amountAfter = await weth.balanceOf(arber.address);

          console.log(
            `Amount earned: ${utils.formatEther(amountAfter.sub(amountBefore))}`
          );
        });
      }
    });
  };

  // Aave version fails due to the flash loan fee
  // testArb("AaveEtherWrapprArb");

  testArb("DyDxEtherWrapprArb");
});

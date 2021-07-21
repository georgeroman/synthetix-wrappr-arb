import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers } from "hardhat";

type ContractDeploymentParams = {
  name: string;
  from: SignerWithAddress;
  args?: any[];
};

export const deployContract = async <T extends Contract>(
  params: ContractDeploymentParams
): Promise<T> => {
  const contractFactory = await ethers.getContractFactory(
    params.name,
    params.from
  );
  const contractInstance = await contractFactory.deploy(...(params.args || []));
  return (await contractInstance.deployed()) as T;
};

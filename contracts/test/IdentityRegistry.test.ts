import { expect } from "chai";
import { ethers } from "hardhat";
import { IdentityRegistry } from "../typechain-types";

describe("IdentityRegistry", function () {
  let identityRegistry: IdentityRegistry;
  let owner: any;
  let user1: any;
  let user2: any;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    const IdentityRegistryFactory = await ethers.getContractFactory("IdentityRegistry");
    identityRegistry = await IdentityRegistryFactory.deploy();
    await identityRegistry.waitForDeployment();
  });

  describe("Registration", function () {
    it("Should allow a user to register their identity", async function () {
      const profileHash = ethers.keccak256(ethers.toUtf8Bytes("test profile"));
      
      await expect(identityRegistry.connect(user1).registerIdentity(profileHash))
        .to.emit(identityRegistry, "IdentityRegistered")
        .withArgs(user1.address, profileHash, await ethers.provider.getBlockNumber() + 1);

      expect(await identityRegistry.isRegistered(user1.address)).to.be.true;
    });

    it("Should prevent duplicate registration", async function () {
      const profileHash = ethers.keccak256(ethers.toUtf8Bytes("test profile"));
      
      await identityRegistry.connect(user1).registerIdentity(profileHash);
      
      await expect(
        identityRegistry.connect(user1).registerIdentity(profileHash)
      ).to.be.revertedWith("Identity already registered");
    });

    it("Should reject invalid profile hash", async function () {
      await expect(
        identityRegistry.connect(user1).registerIdentity(ethers.ZeroHash)
      ).to.be.revertedWith("Invalid profile hash");
    });
  });

  describe("Profile Updates", function () {
    it("Should allow users to update their profile hash", async function () {
      const initialHash = ethers.keccak256(ethers.toUtf8Bytes("initial profile"));
      const newHash = ethers.keccak256(ethers.toUtf8Bytes("updated profile"));
      
      await identityRegistry.connect(user1).registerIdentity(initialHash);
      await identityRegistry.connect(user1).updateProfileHash(newHash);
      
      const identity = await identityRegistry.getIdentity(user1.address);
      expect(identity.profileHash).to.equal(newHash);
    });

    it("Should prevent non-registered users from updating", async function () {
      const newHash = ethers.keccak256(ethers.toUtf8Bytes("new profile"));
      
      await expect(
        identityRegistry.connect(user1).updateProfileHash(newHash)
      ).to.be.revertedWith("Identity not registered");
    });
  });

  describe("Deactivation", function () {
    it("Should allow users to deactivate their identity", async function () {
      const profileHash = ethers.keccak256(ethers.toUtf8Bytes("test profile"));
      
      await identityRegistry.connect(user1).registerIdentity(profileHash);
      await identityRegistry.connect(user1).deactivateIdentity();
      
      expect(await identityRegistry.isRegistered(user1.address)).to.be.false;
    });
  });
});


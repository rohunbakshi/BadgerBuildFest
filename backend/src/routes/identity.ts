import { Router } from "express";
import { ethers } from "ethers";
import User from "../models/User";
import { uploadToIPFS } from "../config/ipfs";

const router = Router();

// Register or update identity
router.post("/register", async (req, res, next) => {
  try {
    const { walletAddress, profileData } = req.body;

    if (!walletAddress || !ethers.isAddress(walletAddress)) {
      return res.status(400).json({ error: "Invalid wallet address" });
    }

    // Calculate profile hash
    const profileJson = JSON.stringify(profileData);
    const profileHash = ethers.keccak256(ethers.toUtf8Bytes(profileJson));

    // Store profile data off-chain
    const ipfsCid = await uploadToIPFS(profileJson);

    // Find or create user
    let user = await User.findOne({ walletAddress: walletAddress.toLowerCase() });
    
    if (user) {
      user.profileHash = profileHash;
      user.profileData = profileData;
      await user.save();
    } else {
      user = await User.create({
        walletAddress: walletAddress.toLowerCase(),
        profileHash,
        profileData,
      });
    }

    res.json({
      walletAddress: user.walletAddress,
      profileHash: user.profileHash,
      ipfsUri: ipfsCid,
    });
  } catch (error) {
    next(error);
  }
});

// Get user profile
router.get("/:address", async (req, res, next) => {
  try {
    const { address } = req.params;

    if (!ethers.isAddress(address)) {
      return res.status(400).json({ error: "Invalid address" });
    }

    const user = await User.findOne({ walletAddress: address.toLowerCase() });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({
      walletAddress: user.walletAddress,
      profileHash: user.profileHash,
      profileData: user.profileData,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    });
  } catch (error) {
    next(error);
  }
});

export default router;


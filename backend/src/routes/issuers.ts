import { Router } from "express";
import { ethers } from "ethers";

const router = Router();

// Register as an issuer (requires admin approval on-chain)
router.post("/register", async (req, res, next) => {
  try {
    const { issuerAddress, issuerData } = req.body;

    if (!ethers.isAddress(issuerAddress)) {
      return res.status(400).json({ error: "Invalid address" });
    }

    // Calculate issuer hash
    const issuerJson = JSON.stringify(issuerData);
    const issuerHash = ethers.keccak256(ethers.toUtf8Bytes(issuerJson));

    // In a real implementation, this would interact with the IssuerRegistry contract
    // For now, we return the hash that should be used in the contract call

    res.json({
      issuerAddress,
      issuerHash,
      message: "Issuer registration initiated. Pending admin approval.",
    });
  } catch (error) {
    next(error);
  }
});

// Get issuer information
router.get("/:address", async (req, res, next) => {
  try {
    const { address } = req.params;

    if (!ethers.isAddress(address)) {
      return res.status(400).json({ error: "Invalid address" });
    }

    // In a real implementation, this would query the IssuerRegistry contract
    res.json({
      issuerAddress: address,
      message: "Query IssuerRegistry contract for issuer status",
    });
  } catch (error) {
    next(error);
  }
});

export default router;


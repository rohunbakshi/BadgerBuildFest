import { Router } from "express";
import { ethers } from "ethers";
import crypto from "crypto";
import AccessGrant from "../models/AccessGrant";

const router = Router();

// Generate access token for resume sharing
router.post("/grant", async (req, res, next) => {
  try {
    const { grantId, ownerAddress, resumeId, expiresAt } = req.body;

    if (!ethers.isAddress(ownerAddress)) {
      return res.status(400).json({ error: "Invalid address" });
    }

    // Generate access token
    const accessToken = crypto.randomBytes(32).toString("hex");
    const accessTokenHash = ethers.keccak256(ethers.hexlify(ethers.toUtf8Bytes(accessToken)));

    const grant = await AccessGrant.create({
      grantId,
      ownerAddress: ownerAddress.toLowerCase(),
      resumeId,
      accessToken: accessTokenHash,
      expiresAt: expiresAt ? new Date(expiresAt) : undefined,
      revoked: false,
    });

    res.json({
      grantId: grant.grantId,
      accessToken, // Return plain token for sharing (hash is stored)
      expiresAt: grant.expiresAt,
    });
  } catch (error) {
    next(error);
  }
});

// Verify access token
router.post("/verify", async (req, res, next) => {
  try {
    const { accessToken } = req.body;

    if (!accessToken) {
      return res.status(400).json({ error: "Access token required" });
    }

    const accessTokenHash = ethers.keccak256(ethers.hexlify(ethers.toUtf8Bytes(accessToken)));

    const grant = await AccessGrant.findOne({ accessToken: accessTokenHash });

    if (!grant) {
      return res.status(404).json({ error: "Invalid access token" });
    }

    if (grant.revoked) {
      return res.status(403).json({ error: "Access token revoked" });
    }

    if (grant.expiresAt && grant.expiresAt < new Date()) {
      return res.status(403).json({ error: "Access token expired" });
    }

    res.json({
      valid: true,
      resumeId: grant.resumeId,
      ownerAddress: grant.ownerAddress,
    });
  } catch (error) {
    next(error);
  }
});

// Revoke access
router.post("/revoke", async (req, res, next) => {
  try {
    const { grantId, ownerAddress } = req.body;

    const grant = await AccessGrant.findOne({ grantId });

    if (!grant) {
      return res.status(404).json({ error: "Grant not found" });
    }

    if (grant.ownerAddress.toLowerCase() !== ownerAddress.toLowerCase()) {
      return res.status(403).json({ error: "Not the grant owner" });
    }

    grant.revoked = true;
    await grant.save();

    res.json({ message: "Access revoked", grantId });
  } catch (error) {
    next(error);
  }
});

export default router;


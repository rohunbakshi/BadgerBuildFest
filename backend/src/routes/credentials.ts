import { Router } from "express";
import { ethers } from "ethers";
import Credential, { CredentialType } from "../models/Credential";
import { uploadToIPFS } from "../config/ipfs";

const router = Router();

// Issue a credential (called by issuer)
router.post("/issue", async (req, res, next) => {
  try {
    const {
      credentialId,
      subjectAddress,
      issuerAddress,
      credentialType,
      data,
    } = req.body;

    if (!ethers.isAddress(subjectAddress) || !ethers.isAddress(issuerAddress)) {
      return res.status(400).json({ error: "Invalid address" });
    }

    // Calculate data hash
    const dataJson = JSON.stringify(data);
    const dataHash = ethers.keccak256(ethers.toUtf8Bytes(dataJson));

    // Store credential data off-chain
    const ipfsCid = await uploadToIPFS(dataJson);

    const credential = await Credential.create({
      credentialId,
      subjectAddress: subjectAddress.toLowerCase(),
      issuerAddress: issuerAddress.toLowerCase(),
      credentialType,
      dataHash,
      data,
      ipfsUri: ipfsCid,
      issuedAt: new Date(),
      expiresAt: data.expiresAt ? new Date(data.expiresAt) : undefined,
      revoked: false,
    });

    res.json({
      credentialId: credential.credentialId,
      dataHash: credential.dataHash,
      ipfsUri: credential.ipfsUri,
    });
  } catch (error) {
    next(error);
  }
});

// Get user's credentials
router.get("/user/:address", async (req, res, next) => {
  try {
    const { address } = req.params;

    if (!ethers.isAddress(address)) {
      return res.status(400).json({ error: "Invalid address" });
    }

    const credentials = await Credential.find({
      subjectAddress: address.toLowerCase(),
      revoked: false,
    }).sort({ issuedAt: -1 });

    res.json(credentials);
  } catch (error) {
    next(error);
  }
});

// Get credential by ID
router.get("/:credentialId", async (req, res, next) => {
  try {
    const { credentialId } = req.params;

    const credential = await Credential.findOne({ credentialId });

    if (!credential) {
      return res.status(404).json({ error: "Credential not found" });
    }

    res.json(credential);
  } catch (error) {
    next(error);
  }
});

// Revoke a credential
router.post("/:credentialId/revoke", async (req, res, next) => {
  try {
    const { credentialId } = req.params;
    const { issuerAddress } = req.body;

    const credential = await Credential.findOne({ credentialId });

    if (!credential) {
      return res.status(404).json({ error: "Credential not found" });
    }

    if (credential.issuerAddress.toLowerCase() !== issuerAddress.toLowerCase()) {
      return res.status(403).json({ error: "Only issuer can revoke" });
    }

    credential.revoked = true;
    await credential.save();

    res.json({ message: "Credential revoked", credentialId });
  } catch (error) {
    next(error);
  }
});

export default router;


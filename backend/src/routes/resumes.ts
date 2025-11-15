import { Router } from "express";
import { ethers } from "ethers";
import Resume from "../models/Resume";
import { uploadToIPFS } from "../config/ipfs";

const router = Router();

// Create a resume
router.post("/create", async (req, res, next) => {
  try {
    const { resumeId, ownerAddress, credentialIds, content } = req.body;

    if (!ethers.isAddress(ownerAddress)) {
      return res.status(400).json({ error: "Invalid address" });
    }

    // Calculate content hash
    const contentJson = JSON.stringify({ credentialIds, content });
    const contentHash = ethers.keccak256(ethers.toUtf8Bytes(contentJson));

    // Store resume content off-chain
    const ipfsCid = await uploadToIPFS(contentJson);

    const resume = await Resume.create({
      resumeId,
      ownerAddress: ownerAddress.toLowerCase(),
      credentialIds,
      contentHash,
      content,
      ipfsUri: ipfsCid,
      isActive: true,
    });

    res.json({
      resumeId: resume.resumeId,
      contentHash: resume.contentHash,
      ipfsUri: resume.ipfsUri,
    });
  } catch (error) {
    next(error);
  }
});

// Get user's resumes
router.get("/user/:address", async (req, res, next) => {
  try {
    const { address } = req.params;

    if (!ethers.isAddress(address)) {
      return res.status(400).json({ error: "Invalid address" });
    }

    const resumes = await Resume.find({
      ownerAddress: address.toLowerCase(),
      isActive: true,
    }).sort({ updatedAt: -1 });

    res.json(resumes);
  } catch (error) {
    next(error);
  }
});

// Get resume by ID
router.get("/:resumeId", async (req, res, next) => {
  try {
    const { resumeId } = req.params;

    const resume = await Resume.findOne({ resumeId, isActive: true });

    if (!resume) {
      return res.status(404).json({ error: "Resume not found" });
    }

    res.json(resume);
  } catch (error) {
    next(error);
  }
});

// Update a resume
router.put("/:resumeId", async (req, res, next) => {
  try {
    const { resumeId } = req.params;
    const { ownerAddress, credentialIds, content } = req.body;

    const resume = await Resume.findOne({ resumeId });

    if (!resume) {
      return res.status(404).json({ error: "Resume not found" });
    }

    if (resume.ownerAddress.toLowerCase() !== ownerAddress.toLowerCase()) {
      return res.status(403).json({ error: "Not the resume owner" });
    }

    // Update content hash
    const contentJson = JSON.stringify({ credentialIds, content });
    const contentHash = ethers.keccak256(ethers.toUtf8Bytes(contentJson));
    const ipfsCid = await uploadToIPFS(contentJson);

    resume.credentialIds = credentialIds;
    resume.content = content;
    resume.contentHash = contentHash;
    resume.ipfsUri = ipfsCid;
    await resume.save();

    res.json({
      resumeId: resume.resumeId,
      contentHash: resume.contentHash,
      ipfsUri: resume.ipfsUri,
    });
  } catch (error) {
    next(error);
  }
});

// Revoke a resume
router.post("/:resumeId/revoke", async (req, res, next) => {
  try {
    const { resumeId } = req.params;
    const { ownerAddress } = req.body;

    const resume = await Resume.findOne({ resumeId });

    if (!resume) {
      return res.status(404).json({ error: "Resume not found" });
    }

    if (resume.ownerAddress.toLowerCase() !== ownerAddress.toLowerCase()) {
      return res.status(403).json({ error: "Not the resume owner" });
    }

    resume.isActive = false;
    await resume.save();

    res.json({ message: "Resume revoked", resumeId });
  } catch (error) {
    next(error);
  }
});

export default router;


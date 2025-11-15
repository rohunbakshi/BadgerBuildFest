import { Router } from "express";
import { verifyResume, getResumeVerification } from "../services/verification";

const router = Router();

/**
 * POST /api/verification/resume
 * Verify a resume against on-chain credentials
 */
router.post("/resume", async (req, res, next) => {
  try {
    const { resumeId, resumeHash, claims } = req.body;
    const result = await verifyResume(resumeId, resumeHash, claims);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/verification/resume/:resumeId
 * Get verification status of a resume
 */
router.get("/resume/:resumeId", async (req, res, next) => {
  try {
    const { resumeId } = req.params;
    const verification = await getResumeVerification(resumeId);
    res.json(verification);
  } catch (error) {
    next(error);
  }
});

export default router;


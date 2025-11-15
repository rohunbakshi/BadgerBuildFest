import { Router } from "express";
import { stakeResume, unstakeResume, claimRewards, getStakingInfo } from "../services/staking";

const router = Router();

/**
 * POST /api/staking/stake
 * Stake a resume
 */
router.post("/stake", async (req, res, next) => {
  try {
    const { resumeId } = req.body;
    const result = await stakeResume(resumeId);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/staking/unstake
 * Unstake a resume
 */
router.post("/unstake", async (req, res, next) => {
  try {
    const { resumeId } = req.body;
    const result = await unstakeResume(resumeId);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/staking/claim
 * Claim staking rewards
 */
router.post("/claim", async (req, res, next) => {
  try {
    const { resumeId } = req.body;
    const result = await claimRewards(resumeId);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/staking/:resumeId
 * Get staking information for a resume
 */
router.get("/:resumeId", async (req, res, next) => {
  try {
    const { resumeId } = req.params;
    const info = await getStakingInfo(resumeId);
    res.json(info);
  } catch (error) {
    next(error);
  }
});

export default router;


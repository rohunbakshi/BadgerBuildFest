import { Router } from "express";
import { createVault, getVaultMatches, updateVaultMatches } from "../services/matching";

const router = Router();

/**
 * POST /api/matching/vault
 * Create a job matching vault
 */
router.post("/vault", async (req, res, next) => {
  try {
    const { vaultId, requiredSkills, skillLevels, stakedOnly } = req.body;
    const result = await createVault(vaultId, requiredSkills, skillLevels, stakedOnly);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/matching/vault/:vaultId
 * Get matching resumes for a vault
 */
router.get("/vault/:vaultId", async (req, res, next) => {
  try {
    const { vaultId } = req.params;
    const matches = await getVaultMatches(vaultId);
    res.json(matches);
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/matching/vault/:vaultId/update
 * Update vault matches
 */
router.post("/vault/:vaultId/update", async (req, res, next) => {
  try {
    const { vaultId } = req.params;
    await updateVaultMatches(vaultId);
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

export default router;


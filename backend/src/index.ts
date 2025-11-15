import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import dotenv from "dotenv";
import { connectDatabase } from "./config/database";
import { errorHandler, notFound } from "./middleware/errorHandler";
import identityRoutes from "./routes/identity";
import credentialRoutes from "./routes/credentials";
import resumeRoutes from "./routes/resumes";
import issuerRoutes from "./routes/issuers";
import accessRoutes from "./routes/access";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:3000",
  credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
});
app.use("/api/", limiter);

// Body parsing
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// API routes
app.use("/api/identity", identityRoutes);
app.use("/api/credentials", credentialRoutes);
app.use("/api/resumes", resumeRoutes);
app.use("/api/issuers", issuerRoutes);
app.use("/api/access", accessRoutes);

// Error handling
app.use(notFound);
app.use(errorHandler);

// Start server
async function start() {
  try {
    await connectDatabase();
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📝 Environment: ${process.env.NODE_ENV || "development"}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
}

start();


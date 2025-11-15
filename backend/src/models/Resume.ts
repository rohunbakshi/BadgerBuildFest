import mongoose, { Schema, Document } from "mongoose";

export interface IResume extends Document {
  resumeId: string;
  ownerAddress: string;
  credentialIds: string[];
  contentHash: string;
  content: {
    summary?: string;
    skills?: string[];
    selfClaimedItems?: Array<{
      type: string;
      title: string;
      description?: string;
      [key: string]: any;
    }>;
  };
  ipfsUri?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const ResumeSchema = new Schema<IResume>(
  {
    resumeId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    ownerAddress: {
      type: String,
      required: true,
      lowercase: true,
      index: true,
    },
    credentialIds: [{
      type: String,
    }],
    contentHash: {
      type: String,
      required: true,
    },
    content: {
      summary: String,
      skills: [String],
      selfClaimedItems: [{
        type: Schema.Types.Mixed,
      }],
    },
    ipfsUri: String,
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model<IResume>("Resume", ResumeSchema);


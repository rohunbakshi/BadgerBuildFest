import mongoose, { Schema, Document } from "mongoose";

export interface IAccessGrant extends Document {
  grantId: string;
  ownerAddress: string;
  employerAddress?: string;
  resumeId: string;
  accessToken: string;
  expiresAt?: Date;
  revoked: boolean;
  createdAt: Date;
}

const AccessGrantSchema = new Schema<IAccessGrant>(
  {
    grantId: {
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
    employerAddress: {
      type: String,
      lowercase: true,
    },
    resumeId: {
      type: String,
      required: true,
      index: true,
    },
    accessToken: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    expiresAt: Date,
    revoked: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
  }
);

export default mongoose.model<IAccessGrant>("AccessGrant", AccessGrantSchema);


import mongoose, { Schema, Document } from "mongoose";

export enum CredentialType {
  Degree = "degree",
  Employment = "employment",
  Certification = "certification",
  Reference = "reference",
}

export interface ICredential extends Document {
  credentialId: string;
  subjectAddress: string;
  issuerAddress: string;
  credentialType: CredentialType;
  dataHash: string;
  data: {
    title?: string;
    description?: string;
    institution?: string;
    startDate?: Date;
    endDate?: Date;
    issuerName?: string;
    [key: string]: any;
  };
  ipfsUri?: string;
  issuedAt: Date;
  expiresAt?: Date;
  revoked: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const CredentialSchema = new Schema<ICredential>(
  {
    credentialId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    subjectAddress: {
      type: String,
      required: true,
      lowercase: true,
      index: true,
    },
    issuerAddress: {
      type: String,
      required: true,
      lowercase: true,
      index: true,
    },
    credentialType: {
      type: String,
      enum: Object.values(CredentialType),
      required: true,
    },
    dataHash: {
      type: String,
      required: true,
    },
    data: {
      type: Schema.Types.Mixed,
      default: {},
    },
    ipfsUri: String,
    issuedAt: {
      type: Date,
      required: true,
    },
    expiresAt: Date,
    revoked: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model<ICredential>("Credential", CredentialSchema);


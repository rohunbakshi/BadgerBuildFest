import mongoose, { Schema, Document } from "mongoose";

export interface IUser extends Document {
  walletAddress: string;
  profileHash: string;
  profileData: {
    name?: string;
    email?: string;
    headline?: string;
    location?: string;
    bio?: string;
  };
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>(
  {
    walletAddress: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      index: true,
    },
    profileHash: {
      type: String,
      required: true,
    },
    profileData: {
      name: String,
      email: String,
      headline: String,
      location: String,
      bio: String,
    },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model<IUser>("User", UserSchema);


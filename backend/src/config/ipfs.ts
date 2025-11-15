import { create } from "ipfs-http-client";

const IPFS_API_URL = process.env.IPFS_API_URL || "http://localhost:5001";
const IPFS_GATEWAY_URL = process.env.IPFS_GATEWAY_URL || "https://ipfs.io/ipfs/";

let ipfsClient: ReturnType<typeof create> | null = null;

export function getIPFSClient() {
  if (!ipfsClient) {
    try {
      ipfsClient = create({ url: IPFS_API_URL });
    } catch (error) {
      console.error("Failed to create IPFS client:", error);
      throw error;
    }
  }
  return ipfsClient;
}

export async function uploadToIPFS(data: string | Uint8Array): Promise<string> {
  const client = getIPFSClient();
  const result = await client.add(data);
  return result.cid.toString();
}

export function getIPFSUrl(cid: string): string {
  return `${IPFS_GATEWAY_URL}${cid}`;
}


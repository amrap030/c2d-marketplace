import { create } from "ipfs-http-client";
import type { CID } from "ipfs-http-client";
import { Buffer } from "buffer/";

const ipfs = create({
  host: "localhost",
  port: 5001,
  protocol: "http",
});

export function useIpfs() {
  /**
   * write json file to ipfs
   * @param content the content to upload to ipfs
   * @returns cid to access the file on ipfs
   */
  const addToIpfs = async (
    content: any,
  ): Promise<{ cid: CID; path: string; size: number }> => {
    content = typeof content === "object" ? JSON.stringify(content) : content;
    try {
      const result = await ipfs.add(Buffer.from(content));
      result.path = `ipfs://${result.path}`;
      return result;
    } catch (e: any) {
      throw new Error(e.toString());
    }
  };

  return { addToIpfs };
}

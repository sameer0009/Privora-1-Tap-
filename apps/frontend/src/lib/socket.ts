import { io } from "socket.io-client";

// Ensure URL matches the local backend
const SIGNALING_URL = process.env.NEXT_PUBLIC_SIGNAL_SERVER || "http://localhost:3001";

export const getSocket = (sessionId: string) => {
  return io(SIGNALING_URL, {
    auth: { sessionId },
    autoConnect: true,
  });
};

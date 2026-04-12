"use client";

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Send, Upload, X, Shield, Lock, Trash2, EyeOff, RadioReceiver, CheckCircle2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { getSocket } from "@/lib/socket";
import { computeSharedSecret, encryptPayload, decryptPayload } from "@/lib/crypto";
import * as idb from "idb-keyval";
import { useRouter } from "next/navigation";
import type { Socket } from "socket.io-client";

interface EncryptedSignal {
  ciphertext: string;
  iv: string;
  isEphemeral: boolean;
}

export default function DashboardPage() {
  const router = useRouter();
  const [socket, setSocket] = useState<Socket | null>(null);
  const [localPubKeyHex, setLocalPubKeyHex] = useState("");
  const [isComposing, setIsComposing] = useState(false);
  
  // Compose States
  const [recipientKey, setRecipientKey] = useState("");
  const [message, setMessage] = useState("");
  const [sendSuccess, setSendSuccess] = useState(false);

  // Inbox States
  const [incoming, setIncoming] = useState<{from: string, signalData: EncryptedSignal}[]>([]);
  const [viewingMessage, setViewingMessage] = useState<string | null>(null);

  useEffect(() => {
    // 1. Initialize local identity logic
    const init = async () => {
      const pubKey = await idb.get<string>("pubKeyHex");
      if (!pubKey) {
        router.push("/auth");
        return;
      }
      setLocalPubKeyHex(pubKey);

      // 2. Connect precisely using identity signature
      const s = getSocket(pubKey);
      setSocket(s);

      s.on("connect", () => console.log("Signaling Server Connected"));

      s.on("signal", async (payload: { from: string, signalData: EncryptedSignal }) => {
        // We received ciphertext via relay!
        setIncoming(prev => [...prev, payload]);
      });
      
      return () => { s.disconnect(); };
    };
    init();
  }, [router]);

  const handleSend = async () => {
    if (!recipientKey || !message || !socket) return;
    try {
      const privKey = await idb.get<CryptoKey>("privKey");
      if (!privKey) throw new Error("No private key");

      // Shared Secret
      const aesKey = await computeSharedSecret(privKey, recipientKey);
      
      // Encrypt
      const { ciphertext, iv } = await encryptPayload(aesKey, message);

      // Route via server
      socket.emit("signal", {
        to: recipientKey,
        signalData: { ciphertext, iv, isEphemeral: true }
      });

      setSendSuccess(true);
      setTimeout(() => {
        setSendSuccess(false);
        setIsComposing(false);
        setMessage("");
      }, 1500);

    } catch (e) {
      console.error("Encryption failed:", e);
      alert("Failed to encrypt. Verify recipient public key.");
    }
  };

  const handleReadMessage = async (index: number) => {
    try {
      const msg = incoming[index];
      const privKey = await idb.get<CryptoKey>("privKey");
      if (!privKey) return;

      const aesKey = await computeSharedSecret(privKey, msg.from);
      const plaintext = await decryptPayload(aesKey, msg.signalData.ciphertext, msg.signalData.iv);

      setViewingMessage(plaintext);

      // **DESTROY AFTER READ LOGIC**
      // Instantly remove ciphertext from local cache once read.
      setIncoming(prev => prev.filter((_, i) => i !== index));

    } catch (e) {
      console.error(e);
      alert("Decryption failed. Spoofed key or corrupted payload.");
    }
  };

  const closeViewer = () => {
    setViewingMessage(null);
    // On close, the plaintext React memory drops.
  };

  return (
    <div className="flex flex-col h-full p-8 relative">
      <header className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-2xl font-semibold mb-1">Active Sessions</h1>
          <p className="text-sm text-muted-foreground font-mono">Your Identity: {localPubKeyHex.slice(0, 16)}...</p>
        </div>
        <Button 
          onClick={() => setIsComposing(true)}
          className="bg-white text-black shadow-[0_0_15px_rgba(255,255,255,0.1)] hover:bg-gray-200 transition-colors gap-2"
        >
          <Send className="w-4 h-4" />
          New Secure Transmission
        </Button>
      </header>

      {/* Inbox List */}
      <div className="flex-1 overflow-y-auto">
        {incoming.length === 0 ? (
          <div className="flex flex-col items-center justify-center text-center max-w-md mx-auto mt-20">
            <div className="w-16 h-16 rounded-2xl glass mb-6 flex items-center justify-center border border-white/5 shadow-2xl">
              <EyeOff className="w-8 h-8 text-muted-foreground" />
            </div>
            <h2 className="text-xl font-medium mb-2">No Active Links</h2>
            <p className="text-sm text-muted-foreground leading-relaxed">
              You currently have no open sessions. When you receive a transmission, it will appear here. Upon reading, it is mathematically obliterated from memory.
            </p>
          </div>
        ) : (
          <div className="grid gap-4">
            {incoming.map((req, idx) => (
              <div key={idx} className="p-4 glass rounded-lg border border-white/10 flex items-center justify-between">
                <div>
                  <div className="text-sm font-medium flex items-center gap-2 text-primary">
                    <RadioReceiver className="w-4 h-4" />
                    Incoming Encrypted Payload
                  </div>
                  <div className="text-xs text-muted-foreground font-mono mt-1">Sender: {req.from.slice(0,16)}...</div>
                </div>
                <Button variant="outline" className="text-white hover:text-black border-white/20" onClick={() => handleReadMessage(idx)}>
                  Decrypt & View
                </Button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Reader Modal (Burn on close) */}
      <AnimatePresence>
        {viewingMessage && (
           <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md"
           >
             <motion.div 
              initial={{ scale: 0.95, y: 10 }}
              animate={{ scale: 1, y: 0 }}
              className="w-full max-w-2xl bg-black border border-red-500/30 rounded-2xl p-8 relative glow shadow-[0_0_50px_rgba(255,0,0,0.1)]"
             >
                <div className="flex items-center gap-2 mb-6 border-b border-white/10 pb-4 text-red-400">
                  <Shield className="w-5 h-5" />
                  <span className="font-semibold uppercase tracking-widest text-sm">Self-Destructing Payload</span>
                </div>
                
                <p className="text-white font-mono text-lg mb-8 leading-relaxed whitespace-pre-wrap">{viewingMessage}</p>

                <Button 
                  onClick={closeViewer} 
                  className="w-full bg-red-950 text-red-500 hover:bg-red-900 transition-colors border border-red-500/50"
                >
                  <Trash2 className="w-4 h-4 mr-2" />
                  Incinerate & Close
                </Button>
             </motion.div>
           </motion.div>
        )}
      </AnimatePresence>

      {/* Compose Overlay */}
      <AnimatePresence>
        {isComposing && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm"
          >
            <motion.div 
              initial={{ scale: 0.95, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.95, y: 20 }}
              transition={{ type: "spring", damping: 25, stiffness: 300 }}
              className="w-full max-w-2xl bg-[#09090b] border border-white/10 rounded-2xl shadow-2xl overflow-hidden flex flex-col relative"
            >
              {sendSuccess && (
                <div className="absolute inset-0 z-10 bg-black/80 backdrop-blur-sm flex flex-col items-center justify-center">
                  <CheckCircle2 className="w-12 h-12 text-primary mb-4" />
                  <span className="font-medium text-white">Transmitted Successfully</span>
                </div>
              )}
              
              <div className="p-4 border-b border-white/5 flex items-center justify-between bg-white/[0.02]">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-md bg-primary/10">
                    <Lock className="w-4 h-4 text-primary" />
                  </div>
                  <span className="font-medium text-sm text-white">Encrypted Transmission</span>
                </div>
                <button 
                  onClick={() => setIsComposing(false)}
                  className="p-2 text-muted-foreground hover:text-white transition-colors rounded-md hover:bg-white/5"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div className="p-6">
                <div className="mb-6 flex items-center gap-3 border-b border-white/5 pb-4">
                  <span className="text-sm text-muted-foreground w-12">To:</span>
                  <input 
                    type="text" 
                    value={recipientKey}
                    onChange={e => setRecipientKey(e.target.value)}
                    placeholder="Recipient Full Public Hex Key" 
                    className="flex-1 bg-transparent text-white font-mono placeholder:text-muted-foreground/30 text-sm focus:outline-none"
                  />
                </div>

                <textarea 
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  placeholder="Draft encrypted payload..." 
                  className="w-full h-40 bg-transparent text-white placeholder:text-muted-foreground/50 resize-none focus:outline-none text-base leading-relaxed"
                />
              </div>

              <div className="p-4 border-t border-white/5 bg-white/[0.02] flex items-center justify-between">
                 <div className="text-xs text-muted-foreground flex gap-2"><Shield className="w-4 text-primary" /> P-256 HKDF / AES-GCM</div>
                 <Button onClick={handleSend} className="bg-primary text-black hover:bg-primary/90 font-medium truncate">
                   Encrypt & Dispatch
                 </Button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

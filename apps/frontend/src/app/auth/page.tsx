"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Shield, KeyRound, Fingerprint, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { generateIdentityKeys } from "@/lib/crypto";
import * as idb from "idb-keyval";
import { useRouter } from "next/navigation";

export default function AuthPage() {
  const [step, setStep] = useState<"initial" | "generating" | "complete">("initial");
  const [fingerprint, setFingerprint] = useState("");
  const router = useRouter();

  // Check if we already have keys
  useEffect(() => {
    idb.get("pubKeyHex").then(res => {
      if (res) {
         setFingerprint(res);
         setStep("complete");
      }
    });
  }, []);

  const startKeyGeneration = async () => {
    setStep("generating");
    
    // Slight artificial delay for dramatic UX
    await new Promise(r => setTimeout(r, 1500));
    
    try {
      const { keyPair, publicKeyHex } = await generateIdentityKeys();
      // Store locally
      await idb.set("privKey", keyPair.privateKey);
      await idb.set("pubKeyHex", publicKeyHex);
      
      setFingerprint(publicKeyHex.slice(0, 16) + '...');
      setStep("complete");
    } catch (e) {
      console.error(e);
      setStep("initial");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center relative p-6">
      <div className="absolute inset-0 bg-background -z-20" />
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-primary/10 via-background to-background -z-10" />

      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-md p-8 glass glow rounded-2xl border border-white/10"
      >
        <div className="flex flex-col items-center text-center space-y-6">
          <div className="w-16 h-16 rounded-2xl bg-white/5 flex items-center justify-center border border-white/10">
            {step === "initial" && <Shield className="w-8 h-8 text-primary" />}
            {step === "generating" && <Loader2 className="w-8 h-8 text-primary animate-spin" />}
            {step === "complete" && <KeyRound className="w-8 h-8 text-green-400" />}
          </div>

          <AnimatePresence mode="wait">
            {step === "initial" && (
              <motion.div
                key="initial"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="w-full"
              >
                <h2 className="text-2xl font-semibold tracking-tight text-white mb-2">
                  Initialize Device
                </h2>
                <p className="text-sm text-muted-foreground mb-8">
                  Your cryptographic identity is bound to this device. No passwords. No server storage.
                </p>
                <Button 
                  onClick={startKeyGeneration}
                  className="w-full h-12 bg-white text-black hover:bg-gray-200 transition-colors shadow-[0_0_20px_rgba(255,255,255,0.15)] gap-2 font-medium"
                >
                  <Fingerprint className="w-5 h-5" />
                  Generate P-256 ECDH Keys
                </Button>
              </motion.div>
            )}

            {step === "generating" && (
              <motion.div
                key="generating"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="w-full space-y-4"
              >
                <h2 className="text-xl font-medium text-white mb-4">Generating Entropy...</h2>
                <div className="w-full bg-white/5 rounded-full h-1 overflow-hidden">
                  <motion.div 
                    className="h-full bg-primary"
                    initial={{ width: "0%" }}
                    animate={{ width: "100%" }}
                    transition={{ duration: 1.5, ease: "easeInOut" }}
                  />
                </div>
              </motion.div>
            )}

            {step === "complete" && (
              <motion.div
                key="complete"
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="w-full"
              >
                <h2 className="text-2xl font-semibold text-white mb-2">Secure Link Established</h2>
                <p className="text-sm text-green-400 mb-8 font-mono bg-green-400/10 p-2 rounded border border-green-400/20">
                  Fingerprint ID: {fingerprint}
                </p>
                <Button 
                  onClick={() => router.push('/dashboard')}
                  className="w-full h-12 bg-primary text-black hover:bg-primary/90 transition-colors gap-2 font-medium"
                >
                  Enter Secure Terminal
                </Button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </motion.div>
    </div>
  );
}

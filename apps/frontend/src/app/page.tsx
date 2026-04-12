"use client";

import { motion } from "framer-motion";
import { Shield, Send, Fingerprint, LockKeyhole } from "lucide-react";
import Link from "next/link";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-6 md:p-24 relative overflow-hidden">
      
      {/* Decorative Grid */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff05_1px,transparent_1px),linear-gradient(to_bottom,#ffffff05_1px,transparent_1px)] bg-[size:4rem_4rem] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_50%,#000_70%,transparent_100%)] -z-10" />

      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
        className="z-10 flex flex-col items-center max-w-3xl text-center"
      >
        <motion.div 
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ delay: 0.2, duration: 0.6 }}
          className="w-16 h-16 rounded-2xl glass glow flex items-center justify-center mb-8 border border-white/10"
        >
          <Shield className="w-8 h-8 text-primary" />
        </motion.div>

        <h1 className="text-5xl md:text-7xl font-semibold tracking-tight text-gradient mb-6">
          Zero Retention.<br /> Absolute Secrecy.
        </h1>
        
        <p className="text-lg md:text-xl text-muted-foreground mb-12 max-w-2xl leading-relaxed">
          1-Tap is an ephemeral E2E encrypted protocol for executive-class communication. Messages and files self-destruct upon reading. Nothing is permanently stored.
        </p>

        <div className="flex flex-col sm:flex-row gap-4 w-full justify-center">
          <Link href="/auth" passHref className="w-full sm:w-auto">
            <motion.button 
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="w-full sm:w-auto px-8 py-4 bg-white text-black font-medium rounded-lg flex items-center justify-center gap-2 transition-all hover:bg-gray-100 shadow-[0_0_20px_rgba(255,255,255,0.15)]"
            >
              <LockKeyhole className="w-5 h-5" />
              Establish Secure Session
            </motion.button>
          </Link>
          <Link href="/about" passHref className="w-full sm:w-auto">
            <motion.button 
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="w-full sm:w-auto px-8 py-4 glass border border-white/10 text-white font-medium rounded-lg flex items-center justify-center gap-2 hover:bg-white/5 transition-colors"
            >
              <Fingerprint className="w-5 h-5" />
              Verify Architecture
            </motion.button>
          </Link>
        </div>
      </motion.div>

      {/* Feature Micro-interactions */}
      <motion.div 
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6, duration: 0.8 }}
        className="mt-32 grid grid-cols-1 md:grid-cols-3 gap-6 max-w-5xl w-full"
      >
        {[
          { icon: Shield, title: "Quantum-Resistant Foundations", desc: "X25519 & Ed25519 powered device chains." },
          { icon: Send, title: "Local & Relay Fallback", desc: "Direct WebRTC over WAN, strict UDP/TCP tunneling." },
          { icon: Fingerprint, title: "Cryptographic Identity", desc: "Device-bound keys. No password vulnerability." },
        ].map((feat, i) => (
          <div key={i} className="p-6 rounded-xl glass border border-white/5 hover:border-white/10 transition-colors group cursor-default">
            <feat.icon className="w-6 h-6 text-muted-foreground group-hover:text-primary transition-colors mb-4" />
            <h3 className="font-medium text-white mb-2">{feat.title}</h3>
            <p className="text-sm text-muted-foreground leading-relaxed">{feat.desc}</p>
          </div>
        ))}
      </motion.div>
    </main>
  );
}

import type { Metadata } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import { cn } from "@/lib/utils";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

const jetbrains = JetBrains_Mono({
  variable: "--font-jetbrains",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "1-Tap | Secure Transmission",
  description: "End-to-end encrypted, zero-retention ephemeral data sharing.",
  themeColor: "#000000",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  // Always dark mode to preserve cybersecurity aesthetic
  return (
    <html lang="en" className="dark" style={{ colorScheme: "dark" }}>
      <body
        className={cn(
          inter.variable,
          jetbrains.variable,
          "min-h-screen bg-background font-sans antialiased text-foreground overflow-x-hidden selection:bg-primary/30"
        )}
      >
        <div className="relative flex min-h-screen flex-col">
          {/* Ambient Background Glow */}
          <div className="pointer-events-none fixed top-0 w-[100vw] h-[100vh] -z-10 overflow-hidden">
            <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-primary/5 blur-[150px]" />
            <div className="absolute bottom-[-10%] right-[-10%] w-[30%] h-[30%] rounded-full bg-[#C471ED]/5 blur-[120px]" />
          </div>
          {children}
        </div>
      </body>
    </html>
  );
}

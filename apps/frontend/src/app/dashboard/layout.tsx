import { Activity, Inbox, ShieldAlert, Settings, FileLock2, Orbit } from "lucide-react";
import Link from "next/link";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex h-screen bg-background text-foreground overflow-hidden">
      
      {/* Sidebar */}
      <aside className="w-64 border-r border-white/5 bg-[#030303] flex flex-col justify-between">
        
        <div className="p-6">
          <Link href="/dashboard" className="flex items-center gap-3 mb-10 group">
            <div className="w-8 h-8 rounded-lg bg-primary/10 flex items-center justify-center border border-primary/30 group-hover:bg-primary/20 transition-colors">
              <Orbit className="w-5 h-5 text-primary" />
            </div>
            <span className="font-semibold tracking-wider text-sm">1-TAP OS</span>
          </Link>
          
          <nav className="space-y-2">
            <Link href="/dashboard" className="flex items-center gap-3 px-3 py-2.5 rounded-lg bg-white/5 text-white text-sm font-medium border border-white/5">
               <Inbox className="w-4 h-4" />
               Active Sessions
            </Link>
            <Link href="/dashboard/transfers" className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-muted-foreground hover:bg-white/5 hover:text-white transition-colors text-sm font-medium">
               <FileLock2 className="w-4 h-4" />
               File Transfers
            </Link>
            <Link href="/dashboard/network" className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-muted-foreground hover:bg-white/5 hover:text-white transition-colors text-sm font-medium inline-flex w-full justify-between">
               <div className="flex items-center gap-3">
                 <Activity className="w-4 h-4" />
                 Network Status
               </div>
               <span className="w-2 h-2 rounded-full bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.6)]"></span>
            </Link>
          </nav>
        </div>

        <div className="p-6 border-t border-white/5">
          <nav className="space-y-2">
            <Link href="/dashboard/security" className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-muted-foreground hover:bg-white/5 hover:text-white transition-colors text-sm font-medium">
               <ShieldAlert className="w-4 h-4" />
               Security Matrix
            </Link>
            <Link href="/dashboard/settings" className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-muted-foreground hover:bg-white/5 hover:text-white transition-colors text-sm font-medium">
               <Settings className="w-4 h-4" />
               Settings 
            </Link>
          </nav>
          
          <div className="mt-6 p-4 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <div className="flex flex-col">
              <span className="text-xs text-muted-foreground">Local Key</span>
              <span className="text-xs font-mono text-white mt-1">0x8f3C...2a1</span>
            </div>
          </div>
        </div>
        
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 flex flex-col relative overflow-y-auto">
        {/* Subtle Background Glows specific to dashboard */}
        <div className="absolute top-[-20%] left-[20%] w-[50%] h-[50%] rounded-full bg-primary/5 blur-[150px] -z-10 pointer-events-none" />
        {children}
      </main>
      
    </div>
  );
}

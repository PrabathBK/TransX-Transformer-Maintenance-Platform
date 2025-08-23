import { Link, useLocation } from "react-router-dom";
import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuItem,
  SidebarMenuButton,
} from "@/components/ui/sidebar";
import { cn } from "@/lib/utils";
import { 
  Zap, 
  Settings, 
  Search, 
  Camera,
  FileImage,
  BarChart3
} from "lucide-react";

const navigation = [
  {
    title: "Transformer",
    items: [
      { name: "Dashboard", href: "/", icon: BarChart3 },
      { name: "Transformers", href: "/transformers", icon: Zap },
      { name: "Inspections", href: "/inspections", icon: Camera },
      { name: "Thermal Images", href: "/images", icon: FileImage },
    ]
  },
  {
    title: "System",
    items: [
      { name: "Settings", href: "/settings", icon: Settings },
    ]
  }
];

export function AppSidebar() {
  const location = useLocation();

  return (
    <Sidebar className="border-r border-sidebar-border bg-sidebar">
      <SidebarHeader className="border-b border-sidebar-border p-6">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-gradient-primary flex items-center justify-center">
            <Zap className="w-5 h-5 text-primary-foreground" />
          </div>
          <div>
            <h1 className="font-bold text-lg text-sidebar-foreground">Oversight</h1>
            <p className="text-xs text-sidebar-foreground/60">Transformer Vision</p>
          </div>
        </div>
      </SidebarHeader>
      
      <SidebarContent className="px-4 py-6">
        {navigation.map((section) => (
          <div key={section.title} className="mb-8">
            <h2 className="mb-4 px-2 text-xs font-semibold text-sidebar-foreground/60 uppercase tracking-wider">
              {section.title}
            </h2>
            <SidebarMenu>
              {section.items.map((item) => {
                const Icon = item.icon;
                const isActive = location.pathname === item.href;
                
                return (
                  <SidebarMenuItem key={item.name}>
                    <SidebarMenuButton
                      asChild
                      className={cn(
                        "w-full justify-start gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all",
                        "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground",
                        isActive && "bg-sidebar-primary text-sidebar-primary-foreground shadow-glow"
                      )}
                    >
                      <Link to={item.href}>
                        <Icon className="w-5 h-5" />
                        {item.name}
                      </Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                );
              })}
            </SidebarMenu>
          </div>
        ))}
      </SidebarContent>
    </Sidebar>
  );
}
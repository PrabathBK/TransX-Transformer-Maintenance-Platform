import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";
import { componentTagger } from "lovable-tagger";

export default defineConfig(({ mode }) => ({
  server: {
    host: "::",
    port: 8081,   // ✅ frontend runs on 8081, backend stays on 8080
    proxy: {
      "/api": {
        target: "http://localhost:8080", // Spring Boot backend
        changeOrigin: true,
        // rewrite: (p) => p.replace(/^\/api/, ""), // enable if your backend paths don’t start with /api
      },
    },
  },
  plugins: [
    react(),
    mode === "development" && componentTagger(),
  ].filter(Boolean),
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
}));

import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Static export disabled - these dynamic pages need runtime
  // output: "export",
  images: { unoptimized: true },
  reactCompiler: true,
  trailingSlash: true,
};

export default nextConfig;

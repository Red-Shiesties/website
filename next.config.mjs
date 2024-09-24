/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config) => {
    config.optimization.minimize = false;
    config.resolve.alias.canvas = false;
    return config;
  },
};

export default nextConfig;

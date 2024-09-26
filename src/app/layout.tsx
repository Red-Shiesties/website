import LayoutProvider from '@/components/layout-provider';
import '@/styles/globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'The Red Shiesties',
  description: 'MOBILITY INDEPENDENCE FOUNDATION WHEELCHAIR REPAIR WEB PORTAL',
};

interface RootLayoutProps {
  children: React.ReactNode;
}

export default function RootLayout({ children }: Readonly<RootLayoutProps>) {
  return (
    <html lang="en">
      <head />
      <LayoutProvider>{children}</LayoutProvider>
    </html>
  );
}

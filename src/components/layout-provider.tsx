'use client';

import Header from '@/components/header';
import { ThemeProvider } from '@/components/theme-provider';
import { cn, fetcher } from '@/lib/utils';
import '@/styles/globals.css';
import { AnimatePresence } from 'framer-motion';
import { Provider } from 'jotai';
import { Inter as FontSans } from 'next/font/google';
import { SWRConfig } from 'swr';

const fontSans = FontSans({
  subsets: ['latin'],
  variable: '--font-sans',
});

interface LayoutProviderProps {
  children: React.ReactNode;
}

export default function LayoutProvider({
  children,
}: Readonly<LayoutProviderProps>) {
  return (
    <body
      className={cn(
        'flex flex-col mx-auto min-h-screen bg-background font-sans antialiased',
        fontSans.variable
      )}
    >
      <AnimatePresence>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <Provider>
            <SWRConfig value={{ fetcher }}>
              <Header />
              <main className="mx-auto flex flex-col max-w-6xl">
                {children}
              </main>
            </SWRConfig>
          </Provider>
        </ThemeProvider>
      </AnimatePresence>
    </body>
  );
}

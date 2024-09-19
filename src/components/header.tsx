'use client';

import { pages } from '@/lib/config';
import { cn } from '@/lib/utils';
import { motion } from 'framer-motion';
import { usePathname } from 'next/navigation';

export default function Header() {
  const pathname = usePathname();

  return (
    <motion.div
      key={'header'}
      initial={{ opacity: 0, y: '-25%' }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, x: '25%' }}
      transition={{ duration: 1 }}
    >
      <header className="flex mx-32 mt-8 justify-between">
        <div className="uppercase font-semibold leading-none">
          <h1>Mobility Independence Foundation Wheelchair</h1>
          <h1>Repair Web Portal</h1>
        </div>
        <div>
          <ul className="flex gap-x-6">
            {pages.map((page) => {
              return (
                <li key={page.name}>
                  <a
                    href={page.pathname}
                    className={cn(
                      'font-semibold transition ease-in-out duration-300 hover:opacity-50',
                      {
                        'underline underline-offset-8':
                          page.pathname === pathname,
                      }
                    )}
                  >
                    {page.name}
                  </a>
                </li>
              );
            })}
          </ul>
        </div>
      </header>
    </motion.div>
  );
}

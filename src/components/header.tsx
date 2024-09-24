import { pages } from '@/lib/config';
import { cn } from '@/lib/utils';
import { usePathname } from 'next/navigation';

export default function Header() {
  const pathname = usePathname();

  return (
    <header className="flex mx-36 mt-8 justify-between items-center">
      <div className="uppercase font-semibold leading-none">
        <h1>Mobility Independence Foundation Wheelchair</h1>
        <h1>Repair Web Portal</h1>
      </div>
      <ul className="flex gap-x-6">
        {pages.map((page) => {
          return (
            <li key={page.name}>
              <a
                href={page.pathname}
                className={cn(
                  'font-semibold transition ease-in-out duration-300 hover:opacity-50',
                  {
                    'underline underline-offset-8': page.pathname === pathname,
                  }
                )}
              >
                {page.name}
              </a>
            </li>
          );
        })}
      </ul>
    </header>
  );
}

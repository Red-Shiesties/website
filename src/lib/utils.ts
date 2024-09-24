import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export async function fetcher(path: string, init: RequestInit) {
  return fetch(path, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
    next: { revalidate: 3600 },
    ...init,
  }).then((res) => res.json());
}

export function formatDateString(date: string) {
  return new Date(date).toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
  });
}

export function converMsToHString(seconds: number) {
  return `${Math.round(seconds / 3600)}h`;
}

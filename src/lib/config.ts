import { Member, Page } from '@/types';

export const pages: Page[] = [
  { name: 'Home', pathname: '/' },
  { name: 'About', pathname: '/about' },
  { name: 'Artifacts', pathname: '/artifacts' },
  { name: 'Metrics', pathname: '/metrics' },
];

export const sections = ['Engineers', 'Sponsor', 'Coach'];

export const members: Member[] = [
  {
    title: 'Website Manager',
    firstName: 'Jon',
    lastName: 'Cruz',
    email: 'jc1831@rit.edu',
    pfp: '',
  },
  {
    title: 'Engineer',
    firstName: 'Jaime',
    lastName: 'Diaz',
    email: 'jsd5582@rit.edu',
    pfp: '',
  },
  {
    title: 'Project Manager',
    firstName: 'Andrew',
    lastName: 'Simpson',
    email: 'aas1984@rit.edu',
    pfp: '',
  },
  {
    title: 'Scrum Master',
    firstName: 'Jonathan',
    lastName: 'Campbel',
    email: 'jc7305@g.rit.edu',
    pfp: '',
  },
  {
    title: 'Sponsor Communication Lead',
    firstName: 'Sam',
    lastName: 'Frost',
    email: 'scf2054@rit.edu',
    pfp: '',
  },
];

export const coach: Member[] = [
  {
    title: 'Coach',
    firstName: 'Samuel',
    lastName: 'Malachowsky',
    email: 'samvse@rit.edu',
    pfp: '/pfp/malachowsky.jpeg',
  },
];

export const sponsors: Member[] = [
  {
    title: 'President',
    firstName: 'Thomas',
    lastName: 'Quiter',
    email: 'example@mail.com',
    pfp: '/pfp/quiter.webp',
  },
  {
    title: 'Vice President',
    firstName: 'Matthew',
    lastName: 'Lacey',
    email: 'example@mail.com',
    pfp: '/pfp/lacey.webp',
  },
  {
    title: 'Chief Growth Officer',
    firstName: 'Jeff',
    lastName: 'Lyons',
    email: 'example@mail.com',
    pfp: '/pfp/lyons.jpeg',
  },
  {
    title: 'Mechanical Engineer',
    firstName: 'Devin',
    lastName: 'Hamilton',
    email: 'example@mail.com',
    pfp: '/pfp/hamilton.png',
  },
];

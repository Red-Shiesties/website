'use client';

import { Card } from '@/components/ui/card';
import {
  Carousel,
  CarouselContent,
  CarouselItem,
} from '@/components/ui/carousel';
import { coach, members, sponsors } from '@/lib/config';
import { Member } from '@/types';
import AutoScroll from 'embla-carousel-auto-scroll';
import { motion } from 'framer-motion';

export default function Home() {
  return (
    <section id="team" className="mt-32 flex flex-col items-center">
      <motion.h2
        initial={{ opacity: 0, y: '-15%' }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1, delay: 0.25 }}
        className="font-thin text-4xl"
      >
        Making an impact by resolving wheelchair repair issues.
      </motion.h2>
      <motion.div
        initial={{ opacity: 0, y: '-5%' }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1, delay: 1.5 }}
      >
        <Carousel
          className="mt-16"
          opts={{ loop: true, align: 'start', skipSnaps: true }}
          plugins={[
            AutoScroll({
              speed: 1,
              startDelay: 3750,
              stopOnInteraction: false,
              stopOnFocusIn: false,
            }),
          ]}
        >
          <CarouselContent>
            {[...coach, ...members, ...sponsors].map((member) => (
              <MemberCard member={member} />
            ))}
          </CarouselContent>
        </Carousel>
      </motion.div>
    </section>
  );
}

interface MemberCardProps {
  member: Member;
}

export const MemberCard = ({ member }: MemberCardProps) => {
  return (
    <CarouselItem
      key={member.firstName}
      className="select-none basis-3/12 md:basis-1/2 lg:basis-1/4"
    >
      <Card
        style={{
          backgroundImage: member.pfp ? `url(${member.pfp})` : undefined,
          background: member.pfp ? undefined : 'transparent',
        }}
        className="cursor-default bg-cover rounded-tl-none aspect-square rounded-tr-3xl rounded-bl-3xl rounded-br-none"
      />
      <div className="mt-3 text-center">
        <p className="text-xl font-semibold">
          {member.firstName} {member.lastName}
        </p>
        <p className="text-md font-thin">{member.title}</p>
      </div>
    </CarouselItem>
  );
};

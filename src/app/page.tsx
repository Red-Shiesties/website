'use client';

import { Card, CardContent } from '@/components/ui/card';
import {
  Carousel,
  CarouselContent,
  CarouselItem,
} from '@/components/ui/carousel';
import { coach, members, sponsors } from '@/lib/config';
import AutoScroll from 'embla-carousel-auto-scroll';
import { motion } from 'framer-motion';
import { useRef } from 'react';

export default function Home() {
  const landingRef = useRef<HTMLElement | null>(null);
  const teamRef = useRef<HTMLElement | null>(null);

  return (
    <main>
      <section
        ref={landingRef}
        id="landing"
        className="flex flex-col items-center"
      >
        <motion.div
          initial={{ opacity: 0, y: '-25%' }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, x: '25%' }}
          transition={{ duration: 1, delay: 0.5 }}
          className="mt-28"
        >
          <h2 className="font-thin text-4xl text-center">
            Making an impact by tackling real-world wheelchair repair issues.
          </h2>
          <Carousel
            className="mt-16 max-w-7xl"
            opts={{ loop: true, align: 'start', skipSnaps: true }}
            plugins={[
              AutoScroll({
                speed: 1,
                startDelay: 5000,
                stopOnInteraction: false,
                stopOnFocusIn: false,
              }),
            ]}
          >
            <CarouselContent>
              {[...coach, ...members, ...sponsors].map((member) => (
                <CarouselItem
                  key={member.firstName}
                  className="md:basis-1/2 lg:basis-1/4"
                >
                  <Card
                    style={{
                      backgroundImage: member.pfp
                        ? `url(${member.pfp})`
                        : undefined,
                      background: member.pfp ? undefined : 'black',
                    }}
                    className="cursor-default bg-cover rounded-tl-none rounded-tr-3xl rounded-bl-3xl rounded-br-none"
                  >
                    <CardContent className="flex flex-col aspect-square">
                      <div className="mt-auto text-white">
                        <p className="text-xl font-semibold">
                          {member.firstName} {member.lastName}
                        </p>
                        <p className="text-md font-thin">{member.title}</p>
                      </div>
                    </CardContent>
                  </Card>
                </CarouselItem>
              ))}
            </CarouselContent>
          </Carousel>
        </motion.div>
        {/* <div>
          <p className="text-2xl font-bold">Meet the team</p>
        </div>
        <div>
          <ul id="members" className="grid grid-flow-col gap-3">
            {members.map((member) => {
              return (
                <li className="size-64 flex flex-col p-3 border-2 border-black rounded" key={member.email}>
                  <div className="mt-auto">
                    <p className="text-lg font-semibold">
                      {member.firstName} {member.lastName}
                    </p>
                    <p className="text-md font-thin">{member.title}</p>
                  </div>
                </li>
              );
            })}
          </ul>
        </div> */}
      </section>
      <section
        ref={teamRef}
        id="landing"
        className="flex flex-col items-center"
      >
        <div></div>
      </section>
    </main>
  );
}

import { Separator } from '@/components/ui/separator';

export default function About() {
  return (
    <>
      <section
        id="background-info"
        className="my-16 flex flex-col items-center gap-y-6"
      >
        <h2 className="text-4xl font-thin">Background Info</h2>
        <div className="flex flex-col gap-y-6">
          <p className="text-lg">
            Researchers estimate that more than 50% of wheelchairs break down in
            a typical six-month period. One study found that among veterans, the
            number is as high as 88% . When a chair breaks, it can take a long
            time to get it fixed; experts put the average wait at two to four
            weeks, but stories of individuals waiting six months or longer for a
            wheelchair repair are common.
          </p>
          <p className="text-lg">
            Several factors contribute to the frequent breakdowns and delays in
            repairs. Some experts attribute these issues to a lack of routine
            maintenance, while others highlight the complexity of modern power
            wheelchairs. Additionally, repairs can be delayed by requirements
            for documentation from insurance companies and a limited inventory
            of common parts.
          </p>
          <p className="text-lg">
            For the roughly 5.5 million Americans using wheelchairs, these
            delays are more than just an inconvenience. While waiting for
            repairs, individuals may find themselves stranded at home, confined
            to bed, or forced to use ill-fitting chairs, which increases the
            risk of developing medical complications and hospitalization.
          </p>
        </div>
      </section>
      <Separator />
      <section
        id="project-description"
        className="my-16 flex flex-col items-center gap-y-6"
      >
        <h2 className="text-4xl font-thin ">Project Description</h2>
        <div className="flex flex-col gap-y-6">
          <p className="text-lg">
            Because the information and the parts are often hard to come by, a
            nonprofit in California and another in New Jersey may have
            complimentary equipment, but the intercompatability of their parts
            and broken wheelchairs are impossible. Without a repository for
            wheelchair repair organizations to communicate, broken wheelchairs
            in California end up in the trash while parts that would fix them
            end up in the trash in New Jersey. We want to be an online
            repository for parts listing and knowledge sharing among nonprofits
            that build wheelchairs for people.
          </p>
        </div>
      </section>
      <Separator />
      <section
        id="challenges"
        className="my-16 flex flex-col items-center gap-y-6"
      >
        <h2 className="text-4xl font-thin ">Challenges</h2>
        <div className="flex flex-col gap-y-6">
          <p className="text-lg">
            Catalog of wheelchair parts and designs will include many different
            types of equipment; building something that can expand as technology
            changes (for example to include remote-controls that work with
            android / apple applications, innovative power supply and motor
            designs, or even different types of mobility articulation (eg. not
            just wheels on a chair, but climbing legs, etc.).
          </p>
          <p className="text-lg">
            The catalog of open-source whitepapers and schematics should promote
            distributed/nonprofit assembly and individual inventor innovation.
            Facilitation of a user community to highlight problems and solutions
            facing mobility independence that will stimulate a global nonprofit
            network to better serve those with mobility challenges.
          </p>
        </div>
      </section>
      <Separator />
      <section
        id="constraints-assumptions"
        className="my-16 flex flex-col items-center gap-y-6"
      >
        <h2 className="text-4xl font-thin ">Constraints & Assumptions</h2>
        <div className="flex flex-col gap-y-6">
          <p className="text-lg">
            Assume there is no existing platform that will meet the project
            goals. User testing w/ early adopters to the platform may be
            constrained because the social network doesn`&apos;t exist yet,
            though the Mobility Independence Foundation will be working
            alongside the project team to address this concern.
          </p>
        </div>
      </section>
    </>
  );
}

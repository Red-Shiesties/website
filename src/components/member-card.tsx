import { Member } from '@/types';

interface MemberCardProps {
  member: Member;
}

export const MemberCard = ({ member }: MemberCardProps) => {
  return (
    <div
      className="size-64 flex flex-col p-3 border-2 border-black rounded"
      key={member.email}
    >
      <div className="mt-auto">
        <p className="text-lg font-semibold">
          {member.firstName} {member.lastName}
        </p>
        <p className="text-md font-thin">{member.title}</p>
      </div>
    </div>
  );
};

'use client';

import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from '@/components/ui/hover-card';
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { cn } from '@/lib/utils';
import {
  BoardDetails,
  BoardMember,
  BoardSprint,
  BoardSprintIssue,
  BoardSprintIssues,
} from '@/types';
import { atom, useAtom, useAtomValue } from 'jotai';
import { useEffect } from 'react';
import useSWR from 'swr';

const sprintAtom = atom<BoardSprint>();

export default function JiraBoard() {
  const [sprint, setSprint] = useAtom(sprintAtom);
  const { data, error, isLoading } = useSWR<BoardDetails>(
    '/api/artifacts/board'
  );

  useEffect(() => {
    if (!data) return;

    const activeSprint = data.sprints.find(
      (sprint) => sprint.state === 'active'
    );
    if (!activeSprint) return;

    setSprint(activeSprint);
  }, [data, setSprint]);

  if (error) return <div>failed to load</div>;
  if (isLoading || !data) return <div>loading...</div>;

  return (
    <div className="flex flex-col gap-y-6">
      <div className="flex justify-between">
        <div className="flex flex-col">
          <h3 className="font-semibold text-lg">{data.project.name}</h3>
          <AvatarGroup members={data.members} />
        </div>
        <div>
          <SprintSelector sprints={data.sprints} />
        </div>
      </div>
      {sprint && <Board columns={data.columns} />}
    </div>
  );
}

interface AvatarGroupProps {
  members: BoardMember[];
}

const AvatarGroup = ({ members }: AvatarGroupProps) => {
  return (
    <div className="flex -space-x-2">
      {members.map((member) => {
        return (
          <HoverCard key={member.displayName} openDelay={0} closeDelay={0}>
            <HoverCardTrigger>
              <Avatar className="border-2 grayscale hover:z-10 hover:grayscale-0">
                <AvatarImage src={member.avatarUrl} />
                <AvatarFallback>DF</AvatarFallback>
              </Avatar>
            </HoverCardTrigger>
            <HoverCardContent
              side="top"
              align="start"
              className="w-auto px-3 py-1 text-sm"
            >
              {member.displayName}
            </HoverCardContent>
          </HoverCard>
        );
      })}
    </div>
  );
};

interface SprintSelectorProps {
  sprints: BoardDetails['sprints'];
}

const SprintSelector = ({ sprints }: SprintSelectorProps) => {
  const [sprint, setSprint] = useAtom(sprintAtom);

  const handleOnValueChange = (value: string) => {
    setSprint(sprints.find((sprint) => sprint.name === value));
  };

  return (
    <Select value={sprint?.name} onValueChange={handleOnValueChange}>
      <SelectTrigger className="w-[180px]">
        <SelectValue placeholder="Select a sprint." />
      </SelectTrigger>
      <SelectContent>
        <SelectGroup>
          {sprints.map((sprint) => {
            return (
              <SelectItem key={sprint.name} value={sprint.name}>
                <div className="flex items-center gap-x-6">
                  <p>{sprint.name}</p>
                  <Badge
                    className={cn({
                      'bg-red-500': sprint.state === 'closed',
                      'bg-green-500': sprint.state === 'active',
                      'bg-blue-500': sprint.state === 'future',
                    })}
                  >
                    {sprint.state}
                  </Badge>
                </div>
              </SelectItem>
            );
          })}
        </SelectGroup>
      </SelectContent>
    </Select>
  );
};

interface BoardProps {
  columns: string[];
}

const Board = ({ columns }: BoardProps) => {
  const sprint = useAtomValue(sprintAtom);

  const { data, error, isLoading } = useSWR<BoardSprintIssues>(
    `/api/artifacts/board/sprint/${sprint?.id}`
  );

  if (error) return <div>failed to load</div>;
  if (isLoading || !data) return <div>loading...</div>;

  return (
    <div className="flex gap-x-9">
      {columns.map((column) => {
        return <BoardColumn key={column} name={column} issues={data.issues} />;
      })}
    </div>
  );
};

interface BoardColumnProps {
  name: string;
  issues: BoardSprintIssue[];
}

const BoardColumn = ({ name, issues }: BoardColumnProps) => {
  const filteredIssues = issues.filter((issue) => issue.status === name);

  return (
    <Card className="w-[350px] rounded-md">
      <CardHeader>
        <CardTitle>
          {name} : {filteredIssues.length}
        </CardTitle>
      </CardHeader>
      <CardContent className="grid grid-flow-row gap-y-3">
        {filteredIssues.map((issue) => (
          <SprintIssue key={issue.id} issue={issue} />
        ))}
      </CardContent>
    </Card>
  );
};

interface SprintIssueProps {
  issue: BoardSprintIssue;
}

const SprintIssue = ({ issue }: SprintIssueProps) => {
  return (
    <Card className="rounded-sm text-sm">
      <CardHeader className="p-3 pb-0">
        <CardTitle>{issue.summary}</CardTitle>
      </CardHeader>
      <CardFooter className="p-3 flex justify-between">
        <div className="flex items-center gap-x-1">
          <Avatar className="h-4 w-4 rounded-none">
            <AvatarImage src={issue.issueType.iconUrl} />
            <AvatarFallback>{issue.issueType.name}</AvatarFallback>
          </Avatar>
          <p className="text-xs font-semibold leading-none tracking-tight">
            {issue.key}
          </p>
        </div>
        {issue.assignee && (
          <div className="flex items-center">
            <Avatar className="h-6 w-6">
              <AvatarImage src={issue.assignee.avatarUrl} />
              <AvatarFallback>{issue.assignee.displayName}</AvatarFallback>
            </Avatar>
          </div>
        )}
      </CardFooter>
    </Card>
  );
};

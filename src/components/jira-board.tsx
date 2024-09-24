'use client';

import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import {
  Card,
  CardContent,
  CardDescription,
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
import { cn, converMsToHString } from '@/lib/utils';
import {
  BoardDetails,
  BoardMember,
  BoardSprint,
  BoardSprintIssue,
  BoardSprintIssues,
} from '@/types';
import { atom, useAtom, useAtomValue, useSetAtom } from 'jotai';
import { useEffect } from 'react';
import useSWR from 'swr';
import { Progress } from './ui/progress';

const sprintAtom = atom<BoardSprint>();
const issuesAtom = atom<BoardSprintIssue[]>();

export default function JiraBoard() {
  const [sprint, setSprint] = useAtom(sprintAtom);
  const issues = useAtomValue(issuesAtom);

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

  const completedTasks =
    issues?.filter((issue) => issue.status === 'Done') || [];
  const progressValue = (completedTasks.length / (issues || []).length) * 100;

  return (
    <div className="flex flex-col gap-y-6">
      <div className="flex justify-center">
        <div className="flex flex-col gap-y-1 mr-auto">
          <p className="text-lg font-semibold">{data.project.name}</p>
          <AvatarGroup members={data.members} />
        </div>
        <div className="flex flex-col gap-y-1 ml-auto">
          <SprintSelector sprints={data.sprints} />
          <Progress className="my-auto" value={progressValue} />
        </div>
      </div>
      <Card className="max-w-6xl p-0 max-h-[42rem] overflow-x-scroll">
        <CardContent className="grid gap-y-9 p-0 py-9">
          {sprint && <BoardMetrics />}
          {sprint && <Board columns={data.columns} />}
        </CardContent>
      </Card>
    </div>
  );
}

const BoardMetrics = () => {
  const issues = useAtomValue(issuesAtom);

  const secondsWorked =
    issues?.reduce((sum, issue) => sum + (issue.timeSpent || 0), 0) || 0;

  const committedPoints =
    issues?.reduce((sum, issue) => sum + (issue.storyPointEstimate || 0), 0) ||
    0;

  const completedPoints =
    issues
      ?.filter((issue) => issue.status === 'Done')
      .reduce((sum, issue) => sum + (issue.storyPointEstimate || 0), 0) || 0;

  return (
    <div className="grid grid-flow-col gap-9 px-9">
      <Card className="rounded-md">
        <CardHeader>
          <CardTitle>Logged Hours</CardTitle>
          <CardDescription>{converMsToHString(secondsWorked)}</CardDescription>
        </CardHeader>
      </Card>
      <Card className="rounded-md">
        <CardHeader>
          <CardTitle>Committed Points</CardTitle>
          <CardDescription>{committedPoints}</CardDescription>
        </CardHeader>
      </Card>
      <Card className="rounded-md">
        <CardHeader>
          <CardTitle>Completed Points</CardTitle>
          <CardDescription>{completedPoints}</CardDescription>
        </CardHeader>
      </Card>
    </div>
  );
};

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
  const setIssues = useSetAtom(issuesAtom);
  const sprint = useAtomValue(sprintAtom);

  const { data, error, isLoading } = useSWR<BoardSprintIssues>(
    `/api/artifacts/board/sprint/${sprint?.id}`
  );

  useEffect(() => {
    if (!data) return;

    setIssues(data.issues);
  }, [data, setIssues]);

  if (error) return <div>failed to load</div>;
  if (isLoading || !data) return <div>loading...</div>;

  return (
    <div className="flex gap-x-9 justify-center px-9">
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
        <CardTitle>{name}</CardTitle>
        <CardDescription>{filteredIssues.length} items</CardDescription>
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
    <Card className="rounded-md text-sm">
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
        <div className="flex items-center gap-x-3">
          {issue.storyPointEstimate && (
            <div className="flex items-center justify-center rounded-full h-6 w-6 text-xs bg-secondary">
              {issue.storyPointEstimate}
            </div>
          )}
          {issue.assignee && (
            <div className="flex items-center">
              <Avatar className="h-6 w-6">
                <AvatarImage src={issue.assignee.avatarUrl} />
                <AvatarFallback>{issue.assignee.displayName}</AvatarFallback>
              </Avatar>
            </div>
          )}
        </div>
      </CardFooter>
    </Card>
  );
};

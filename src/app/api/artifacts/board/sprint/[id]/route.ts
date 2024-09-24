import { executeGET } from '@/lib/jira';
import {
  BoardSprintIssue,
  BoardSprintIssues,
  JiraBoardSprintIssue,
} from '@/types';
import { NextResponse } from 'next/server';

type Context = {
  params: {
    id: string;
  };
};

export async function GET(
  request: Request,
  { params }: Context
): Promise<NextResponse<BoardSprintIssues>> {
  const sprint = await executeGET<JiraBoardSprintIssue>(
    `/rest/agile/1.0/board/${process.env.JIRA_BOARD_ID}/sprint/${params.id}/issue`
  );

  return NextResponse.json(
    {
      issues:
        sprint?.issues.map<BoardSprintIssue>((issue) => {
          return {
            id: issue.id,
            key: issue.key,
            issueType: {
              iconUrl: issue.fields.issuetype.iconUrl,
              description: issue.fields.issuetype.description,
              name: issue.fields.issuetype.name,
            },
            priority: {
              iconUrl: issue.fields.priority.iconUrl,
              name: issue.fields.priority.name,
            },
            assignee: issue.fields.assignee
              ? {
                  avatarUrl: issue.fields.assignee.avatarUrls['48x48'],
                  displayName: issue.fields.assignee.displayName,
                  active: issue.fields.assignee.active,
                }
              : undefined,
            timeTracking: issue.fields.timetracking,
            status: issue.fields.status.name,
            description: issue.fields.description,
            summary: issue.fields.summary,
            timeSpent: issue.fields.timespent,
          };
        }) || [],
    },
    { status: 200 }
  );
}

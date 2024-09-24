import { executeGET } from '@/lib/jira';
import {
  BoardDetails,
  JiraBoardConfiguration,
  JiraBoardSprint,
  JiraProjectRole,
  JiraUser,
} from '@/types';
import { NextResponse } from 'next/server';

// TODO: handle pagination (if needed)

export async function GET(): Promise<NextResponse<BoardDetails>> {
  const boardConfig = await executeGET<JiraBoardConfiguration>(
    `/rest/agile/1.0/board/${process.env.JIRA_BOARD_ID}/configuration`
  );
  const sprint = await executeGET<JiraBoardSprint>(
    `/rest/agile/1.0/board/${process.env.JIRA_BOARD_ID}/sprint`
  );
  const role = await executeGET<JiraProjectRole>(
    `/rest/api/3/project/${boardConfig?.location.id}/role/${process.env.JIRA_ADMIN_ROLE_ID}`
  );

  const users = await Promise.all(
    role?.actors.map((actor) => {
      return executeGET<JiraUser>(
        `/rest/api/2/user?accountId=${actor.actorUser.accountId}`
      );
    }) || []
  );

  return NextResponse.json(
    {
      project: {
        name: boardConfig?.location.name || '',
        id: boardConfig?.location.id || '',
      },
      columns:
        boardConfig?.columnConfig.columns.map((column) => column.name) || [],
      sprints:
        sprint?.values.map(
          ({ id, state, name, startDate, endDate, completeDate }) => ({
            id,
            state,
            name,
            startDate,
            endDate,
            completeDate,
          })
        ) || [],
      members: users
        .filter((user) => user !== undefined)
        .map((user) => {
          return {
            avatarUrl: user.avatarUrls['48x48'],
            displayName: user.displayName,
            active: user.active,
          };
        }),
    },
    { status: 200 }
  );
}

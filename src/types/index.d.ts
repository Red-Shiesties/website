export type Page = {
  name: string;
  pathname: string;
};

export type Member = {
  title: string;
  firstName: string;
  lastName: string;
  email: string;
  pfp: string;
};

// export type Actor = {};

export type BoardDetails = {
  project: {
    id: string;
    name: string;
  };
  columns: string[];
  sprints: BoardSprint[];
  members: BoardMember[];
};

export type BoardMember = {
  avatarUrl: string;
  displayName: string;
  active: boolean;
};

export type BoardSprint = {
  id: int;
  state: string;
  name: string;
  startDate: string;
  endDate: string;
  completeDate?: string;
};

export type BoardSprintIssues = {
  issues: BoardSprintIssue[];
};

export type BoardSprintIssue = {
  id: string;
  key: string;
  issueType: {
    iconUrl: string;
    description: string;
    name: string;
  };
  priority: {
    iconUrl: string;
    name: string;
  };
  assignee?: {
    avatarUrl: string;
    displayName: string;
    active: boolean;
  };
  status: string;
  description: string | null;
  summary: string;
};

// Jira API Definitions (only defining the ones we care about)

export type JiraBoardConfiguration = {
  location: {
    id: string;
    name: string;
  };
  columnConfig: {
    columns: { name: string }[];
  };
};

export type JiraBoardSprint = {
  maxResults: int;
  startAt: int;
  total: int;
  isLast: boolean;
  values: {
    id: int;
    state: string;
    name: string;
    startDate: string;
    endDate: string;
    completeDate?: string;
    createdDate: string;
  }[];
};

export type JiraBoardSprintIssue = {
  startAt: int;
  maxResults: int;
  total: int;
  issues: {
    id: string;
    key: string;
    fields: {
      issuetype: {
        iconUrl: string;
        description: string;
        name: string;
      };
      timespent: int | null;
      created: string;
      priority: {
        iconUrl: string;
        name: string;
      };
      assignee: {
        avatarUrls: {
          '48x48': string;
          '32x32': string;
          '24x24': string;
          '16x16': string;
        };
        displayName: string;
        active: boolean;
      } | null;
      status: {
        name: string;
      };
      description: string;
      timetracking?: {
        remainingEstimate: string;
        timeSpent: string;
        remainingEstimateSeconds: int;
        timeSpentSeconds: int;
      };
      summary: string;
      subtasks: {
        key: string;
        fields: { summary: string; status: { name: string } };
        priority: { name: string; iconUrl: string };
      }[];
    };
  }[];
};

export type JiraProjectRole = {
  name: string;
  description: string;
  actors: {
    id: string;
    displayName: string;
    actorUser: {
      accountId: string;
    };
  }[];
};

export type JiraUser = {
  accountId: string;
  avatarUrls: {
    '48x48': string;
    '32x32': string;
    '24x24': string;
    '16x16': string;
  };
  displayName: string;
  active: boolean;
};
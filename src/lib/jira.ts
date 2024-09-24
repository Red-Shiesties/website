export const executeGET = async <T>(path: string): Promise<T | undefined> => {
  try {
    const res = await fetch(process.env.JIRA_API_URL + path, {
      method: 'GET',
      headers: {
        authorization: `Basic ${process.env.JIRA_API_KEY}`,
        'content-type': 'application/json',
      },
      next: {
        revalidate: 3600,
      },
    });
    return await res.json();
  } catch (error) {
    console.error(error);
    return undefined;
  }
};

import JiraBoard from '@/components/jira-board';

export default function Metrics() {
  return (
    <section
      id="jira-board"
      className="mt-16 flex flex-col items-center gap-y-6"
    >
      <h2 className="text-4xl font-thin">Project Board</h2>
      <JiraBoard />
    </section>
  );
}

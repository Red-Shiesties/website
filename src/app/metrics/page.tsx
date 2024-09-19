import JiraBoard from '@/components/jira-board';

export default function Metrics() {
  return (
    <main>
      <section id="jira-board" className="flex flex-col items-center gap-y-6">
        <h2 className="text-4xl font-thin">View our board!</h2>
        <JiraBoard />
      </section>
    </main>
  );
}

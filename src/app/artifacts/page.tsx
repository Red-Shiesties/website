import { ArtifactsViewer } from '@/components/artifacts-viewer';
import { TreeContent } from '@/types';
import { promises as fs } from 'fs';
import path from 'path';

const getArtifactsTree = async (path: string): Promise<TreeContent[]> => {
  const startingPath = process.cwd() + '/public';
  const dirents = (
    await fs.readdir(path, {
      withFileTypes: true,
    })
  ).filter((dirent) => {
    if (dirent.isDirectory()) return true;
    return dirent.name.endsWith('.pdf');
  });

  return Promise.all(
    dirents.map(async (dirent) => {
      if (dirent.isDirectory()) {
        const files = await getArtifactsTree(
          dirent.parentPath + '/' + dirent.name
        );

        return {
          type: 'folder',
          name: dirent.name,
          path: dirent.parentPath.replace(startingPath, ''),
          files,
        };
      }

      return {
        type: 'file',
        name: dirent.name,
        path: `${dirent.parentPath.replace(startingPath, '')}/${dirent.name}`,
      };
    })
  );
};

export default async function Artifacts() {
  const artifacts = await getArtifactsTree(
    path.join(process.cwd(), '/public/artifacts')
  );

  return (
    <section
      id="jira-board"
      className="mt-16 flex flex-col items-center gap-y-6"
    >
      <h2 className="text-4xl font-thin">Artifacts</h2>
      <ArtifactsViewer artifacts={artifacts} />
    </section>
  );
}

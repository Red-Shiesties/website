'use client';

import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { ArtifactsNode, TreeContent } from '@/types';
import {
  ArrowLeftIcon,
  DoubleArrowLeftIcon,
  DoubleArrowRightIcon,
  FileTextIcon,
  PlusCircledIcon,
} from '@radix-ui/react-icons';
import { useResizeObserver } from '@wojtekmaj/react-hooks';
import type { PDFDocumentProxy } from 'pdfjs-dist';
import { useCallback, useState } from 'react';
import { Document, Page, pdfjs } from 'react-pdf';
import 'react-pdf/dist/Page/AnnotationLayer.css';
import 'react-pdf/dist/Page/TextLayer.css';
import { SelectSeparator } from './ui/select';

pdfjs.GlobalWorkerOptions.workerSrc = new URL(
  'pdfjs-dist/build/pdf.worker.min.mjs',
  import.meta.url
).toString();

interface ArtifactsViewerProps {
  artifacts: TreeContent[];
}

export const ArtifactsViewer = ({ artifacts }: ArtifactsViewerProps) => {
  const [node, setNode] = useState<ArtifactsNode>({ artifacts });

  const [file, setFile] = useState<TreeContent>();
  const [numPages, setNumPages] = useState(0);
  const [page, setPage] = useState(1);
  const [containerRef] = useState<HTMLElement | null>(null);
  const [containerWidth, setContainerWidth] = useState<number>(800);

  const onResize = useCallback<ResizeObserverCallback>((entries) => {
    const [entry] = entries;

    if (entry) {
      setContainerWidth(entry.contentRect.width);
    }
  }, []);

  useResizeObserver(containerRef, {}, onResize);

  const handleTraverseForward = (artifact: TreeContent) => {
    if (artifact.files) {
      setNode({ previous: node, artifacts: artifact.files });
    } else {
      setFile(artifact);
    }
  };

  const handleTraverseBackward = () => {
    if (node.previous) {
      setNode(node.previous);
    }
  };

  const onDocumentLoadSuccess = ({ numPages }: PDFDocumentProxy) => {
    setNumPages(numPages);
    setPage(1);
  };

  return (
    <div className="flex gap-x-3">
      <Card className="rounded-sm">
        <CardHeader>
          <CardTitle>Directory</CardTitle>
        </CardHeader>
        <CardContent className="grid grid-flow-row gap-y-3">
          <div>
            <Button
              variant={'ghost'}
              disabled={!node.previous}
              onClick={handleTraverseBackward}
              className="border justify-between w-64"
            >
              Back
              <ArrowLeftIcon />
            </Button>
            <SelectSeparator className="mt-6 mb-3" />
          </div>
          {node.artifacts.map((artifact) => {
            return (
              <Button
                key={artifact.name}
                variant={'ghost'}
                className="border justify-between w-64"
                onClick={() => handleTraverseForward(artifact)}
              >
                {artifact.name}
                {artifact.files ? <PlusCircledIcon /> : <FileTextIcon />}
              </Button>
            );
          })}
        </CardContent>
      </Card>
      <Card className="rounded-sm">
        <CardHeader>
          <CardTitle>File Viewer</CardTitle>
        </CardHeader>
        <CardContent className="overflow-scroll">
          <div className="flex gap-x-3 mb-6 justify-end">
            <Button
              variant={'outline'}
              disabled={page === 1}
              onClick={() => setPage(page - 1)}
              className="gap-x-3"
            >
              <DoubleArrowLeftIcon />
              Previous Page
            </Button>
            <Button
              variant={'outline'}
              disabled={numPages === 0 || page === numPages}
              onClick={() => setPage(page + 1)}
              className="gap-x-3"
            >
              Next Page
              <DoubleArrowRightIcon />
            </Button>
          </div>
          <Document
            noData={<ViewerNoData />}
            loading={<ViewerLoading />}
            error={<ViewerError />}
            className={'w-[55rem] h-[35rem] border rounded-sm overflow-scroll'}
            file={file?.path}
            onLoadSuccess={onDocumentLoadSuccess}
          >
            <Page
              key={`page_${page}`}
              pageNumber={page}
              width={containerWidth}
            />
          </Document>
        </CardContent>
      </Card>
    </div>
  );
};

const ViewerNoData = () => {
  return <div>Select a PDF file from the directory.</div>;
};

const ViewerLoading = () => {
  return <div>Rendering PDF file.</div>;
};

const ViewerError = () => {
  return <div>There was an error loading the PDF file.</div>;
};

'use client';

interface ErrorProps {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function ErrorBoundary({ error, reset }: ErrorProps) {
  return (
    <div className="rounded-lg border border-red-200 bg-red-50 p-6 text-center" role="alert">
      <h2 className="text-lg font-semibold text-red-800">Something went wrong</h2>
      <p className="mt-2 text-sm text-red-600">
        {error.message || 'Failed to load user data'}
      </p>
      <button
        onClick={reset}
        className="mt-4 rounded-md bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700"
      >
        Try again
      </button>
    </div>
  );
}

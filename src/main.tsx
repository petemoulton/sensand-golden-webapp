import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import './index.css';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000, // 1 minute
      retry: 1,
    },
  },
});

function App() {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          Sensand Golden Path
        </h1>
        <p className="text-gray-600 mb-8">
          Template repository ready. Start building with <code>pnpm gen:feature</code>
        </p>
        <div className="space-y-2 text-sm text-gray-500">
          <p>✅ Hexagonal architecture</p>
          <p>✅ Type-safe API client</p>
          <p>✅ React Query + Zustand</p>
          <p>✅ Tailwind + Radix UI</p>
        </div>
      </div>
    </div>
  );
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  </StrictMode>
);

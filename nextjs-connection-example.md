# Connecting Next.js to Self-Hosted Convex

## Step-by-Step Guide

### 1. Install Dependencies

```bash
npm install convex
```

### 2. Environment Variables

Create or update `.env.local` in your Next.js project:

```env
NEXT_PUBLIC_CONVEX_URL=http://localhost:3210
CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key_from_convex_backend
```

### 3. Initialize Convex in Your Project

```bash
npx convex dev --url http://localhost:3210 --admin-key your_admin_key_from_convex_backend
```

This will:
- Create `convex/` directory with schema
- Generate `convex/_generated/api.d.ts`
- Connect to your self-hosted instance

### 4. Create Convex Provider (App Router)

```typescript
// app/providers.tsx
"use client";

import { ConvexProvider, ConvexReactClient } from "convex/react";

const convex = new ConvexReactClient(
  process.env.NEXT_PUBLIC_CONVEX_URL!
);

export function Providers({ children }: { children: React.ReactNode }) {
  return <ConvexProvider client={convex}>{children}</ConvexProvider>;
}
```

```typescript
// app/layout.tsx
import { Providers } from "./providers";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</body>
      </Providers>
    </html>
  );
}
```

### 5. Use Convex in Components

```typescript
// app/page.tsx
"use client";

import { useQuery } from "convex/react";
import { api } from "../convex/_generated/api";

export default function Home() {
  const data = useQuery(api.myFunction);
  
  return <div>{/* Your component */}</div>;
}
```

### 6. Verification Command

Test the connection:

```bash
npx convex dev --url http://localhost:3210 --admin-key YOUR_ADMIN_KEY
```

Expected output:
```
✓ Connected to Convex deployment
✓ Synced schema
```

## Alternative: Using HTTP Client (No React Hooks)

```typescript
// lib/convex.ts
import { ConvexHttpClient } from "convex/browser";

export const convexClient = new ConvexHttpClient(
  process.env.NEXT_PUBLIC_CONVEX_URL!
);
```

```typescript
// Usage in Server Components or API Routes
import { convexClient } from "@/lib/convex";
import { api } from "@/convex/_generated/api";

const result = await convexClient.query(api.myFunction, {});
```

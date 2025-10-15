# Frontend Optimization Operation

You are executing the **frontend** operation to optimize frontend bundle size, rendering performance, asset loading, and Web Vitals.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'frontend' operation name)

Expected format: `target:"bundles|rendering|assets|images|fonts|all" [pages:"page-list"] [metrics_target:"lighthouse-score"] [framework:"react|vue|angular|svelte"]`

**Parameter definitions**:
- `target` (required): What to optimize - `bundles`, `rendering`, `assets`, `images`, `fonts`, or `all`
- `pages` (optional): Specific pages to optimize (comma-separated, e.g., "dashboard,profile,checkout")
- `metrics_target` (optional): Target Lighthouse score (e.g., "lighthouse>90", "lcp<2.5s")
- `framework` (optional): Framework being used - `react`, `vue`, `angular`, `svelte` (auto-detected if not specified)

## Workflow

### 1. Detect Frontend Framework and Build Tool

```bash
# Check framework
grep -E "\"react\"|\"vue\"|\"@angular\"|\"svelte\"" package.json | head -5

# Check build tool
grep -E "\"webpack\"|\"vite\"|\"parcel\"|\"rollup\"|\"esbuild\"" package.json | head -5

# Check for Next.js, Nuxt, etc.
ls next.config.js nuxt.config.js vite.config.js webpack.config.js 2>/dev/null
```

### 2. Run Performance Audit

**Lighthouse Audit**:
```bash
# Single page audit
npx lighthouse https://your-app.com --output=json --output-path=./audit-baseline.json --view

# Multiple pages
for page in dashboard profile checkout; do
  npx lighthouse "https://your-app.com/$page" \
    --output=json \
    --output-path="./audit-$page.json"
done

# Use Lighthouse CI for automated audits
npm install -g @lhci/cli
lhci autorun --config=lighthouserc.json
```

**Bundle Analysis**:
```bash
# Webpack Bundle Analyzer
npm run build -- --stats
npx webpack-bundle-analyzer dist/stats.json

# Vite bundle analysis
npx vite-bundle-visualizer

# Next.js bundle analysis
npm install @next/bundle-analyzer
# Then configure in next.config.js
```

### 3. Bundle Optimization

#### 3.1. Code Splitting by Route

**React (with React Router)**:
```javascript
// BEFORE (everything in one bundle)
import Dashboard from './pages/Dashboard';
import Profile from './pages/Profile';
import Settings from './pages/Settings';

function App() {
  return (
    <Routes>
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/profile" element={<Profile />} />
      <Route path="/settings" element={<Settings />} />
    </Routes>
  );
}
// Result: 2.5MB initial bundle

// AFTER (lazy loading by route)
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Profile = lazy(() => import('./pages/Profile'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
// Result: 450KB initial + 3 smaller chunks
// Improvement: 82% smaller initial bundle
```

**Next.js (automatic code splitting)**:
```javascript
// Next.js automatically splits by page, but you can add dynamic imports:
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(() => import('../components/HeavyChart'), {
  loading: () => <p>Loading chart...</p>,
  ssr: false // Don't render on server if not needed
});

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <HeavyComponent data={data} />
    </div>
  );
}
```

**Vue (with Vue Router)**:
```javascript
// BEFORE
import Dashboard from './views/Dashboard.vue';
import Profile from './views/Profile.vue';

const routes = [
  { path: '/dashboard', component: Dashboard },
  { path: '/profile', component: Profile }
];

// AFTER (lazy loading)
const routes = [
  { path: '/dashboard', component: () => import('./views/Dashboard.vue') },
  { path: '/profile', component: () => import('./views/Profile.vue') }
];
```

#### 3.2. Tree Shaking and Dead Code Elimination

**Proper Import Strategy**:
```javascript
// BEFORE (imports entire library)
import _ from 'lodash'; // 70KB
import moment from 'moment'; // 232KB
import { Button, Modal, Table, Form, Input } from 'antd'; // Imports all

const formatted = moment().format('YYYY-MM-DD');
const debounced = _.debounce(fn, 300);

// AFTER (tree-shakeable imports)
import { debounce } from 'lodash-es'; // 2KB (tree-shakeable)
import { format } from 'date-fns'; // 12KB (tree-shakeable)
import Button from 'antd/es/button'; // Import only what's needed
import Modal from 'antd/es/modal';

const formatted = format(new Date(), 'yyyy-MM-dd');
const debounced = debounce(fn, 300);

// Bundle size reduction: ~290KB → ~20KB (93% smaller)
```

**Webpack Configuration**:
```javascript
// webpack.config.js
module.exports = {
  mode: 'production',
  optimization: {
    usedExports: true, // Tree shaking
    sideEffects: false, // Assume no side effects (check package.json)
    minimize: true,
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 10
        },
        common: {
          minChunks: 2,
          priority: 5,
          reuseExistingChunk: true
        }
      }
    }
  }
};
```

#### 3.3. Remove Unused Dependencies

```bash
# Analyze unused dependencies
npx depcheck

# Example output:
# Unused dependencies:
#   * moment (use date-fns instead)
#   * jquery (not used in React app)
#   * bootstrap (using Tailwind instead)

# Remove them
npm uninstall moment jquery bootstrap

# Check bundle impact
npm run build
```

#### 3.4. Optimize Bundle Chunks

```javascript
// Vite config for optimal chunking
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor-react': ['react', 'react-dom', 'react-router-dom'],
          'vendor-ui': ['antd', '@ant-design/icons'],
          'vendor-utils': ['axios', 'lodash-es', 'date-fns']
        }
      }
    },
    chunkSizeWarningLimit: 500 // Warn if chunk > 500KB
  }
});

// Next.js config for optimal chunking
module.exports = {
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.optimization.splitChunks = {
        chunks: 'all',
        cacheGroups: {
          default: false,
          vendors: false,
          framework: {
            name: 'framework',
            chunks: 'all',
            test: /(?<!node_modules.*)[\\/]node_modules[\\/](react|react-dom|scheduler|prop-types)[\\/]/,
            priority: 40,
            enforce: true
          },
          lib: {
            test: /[\\/]node_modules[\\/]/,
            name: 'lib',
            priority: 30,
            minChunks: 1,
            reuseExistingChunk: true
          }
        }
      };
    }
    return config;
  }
};
```

### 4. Rendering Optimization

#### 4.1. React - Prevent Unnecessary Re-renders

**Memoization**:
```javascript
// BEFORE (re-renders on every parent update)
function UserList({ users, onSelect }) {
  return users.map(user => (
    <UserCard key={user.id} user={user} onSelect={onSelect} />
  ));
}

function UserCard({ user, onSelect }) {
  console.log('Rendering UserCard:', user.id);
  return (
    <div onClick={() => onSelect(user)}>
      {user.name} - {user.email}
    </div>
  );
}
// Result: All cards re-render even if only one user changes

// AFTER (memoized components)
import { memo, useCallback, useMemo } from 'react';

const UserCard = memo(({ user, onSelect }) => {
  console.log('Rendering UserCard:', user.id);
  return (
    <div onClick={() => onSelect(user)}>
      {user.name} - {user.email}
    </div>
  );
});

function UserList({ users, onSelect }) {
  const memoizedOnSelect = useCallback(onSelect, []); // Stable reference

  return users.map(user => (
    <UserCard key={user.id} user={user} onSelect={memoizedOnSelect} />
  ));
}
// Result: Only changed cards re-render
// Performance: 90% fewer renders for 100 cards
```

**useMemo for Expensive Computations**:
```javascript
// BEFORE (recalculates on every render)
function Dashboard({ data }) {
  const stats = calculateComplexStats(data); // Expensive: 50ms

  return <StatsDisplay stats={stats} />;
}
// Result: 50ms wasted on every render, even if data unchanged

// AFTER (memoized calculation)
function Dashboard({ data }) {
  const stats = useMemo(
    () => calculateComplexStats(data),
    [data] // Only recalculate when data changes
  );

  return <StatsDisplay stats={stats} />;
}
// Result: 0ms for unchanged data, 50ms only when data changes
```

#### 4.2. Virtual Scrolling for Long Lists

```javascript
// BEFORE (renders all 10,000 items)
function LargeList({ items }) {
  return (
    <div className="list">
      {items.map(item => (
        <ListItem key={item.id} data={item} />
      ))}
    </div>
  );
}
// Result: Initial render: 2,500ms, 10,000 DOM nodes

// AFTER (virtual scrolling with react-window)
import { FixedSizeList } from 'react-window';

function LargeList({ items }) {
  const Row = ({ index, style }) => (
    <div style={style}>
      <ListItem data={items[index]} />
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}
// Result: Initial render: 45ms, only ~20 visible DOM nodes
// Performance: 98% faster, 99.8% fewer DOM nodes
```

#### 4.3. Debounce Expensive Operations

```javascript
// BEFORE (triggers on every keystroke)
function SearchBox() {
  const [query, setQuery] = useState('');

  const handleSearch = (value) => {
    setQuery(value);
    fetchResults(value); // API call on every keystroke
  };

  return <input onChange={(e) => handleSearch(e.target.value)} />;
}
// Result: 50 API calls for typing "performance optimization"

// AFTER (debounced search)
import { useMemo } from 'react';
import { debounce } from 'lodash-es';

function SearchBox() {
  const [query, setQuery] = useState('');

  const debouncedSearch = useMemo(
    () => debounce((value) => fetchResults(value), 300),
    []
  );

  const handleSearch = (value) => {
    setQuery(value);
    debouncedSearch(value);
  };

  return <input onChange={(e) => handleSearch(e.target.value)} />;
}
// Result: 1-2 API calls for typing "performance optimization"
// Performance: 96% fewer API calls
```

### 5. Image Optimization

#### 5.1. Modern Image Formats

```javascript
// BEFORE (traditional formats)
<img src="/images/hero.jpg" alt="Hero" />
// hero.jpg: 1.2MB

// AFTER (modern formats with fallback)
<picture>
  <source srcset="/images/hero.avif" type="image/avif" />
  <source srcset="/images/hero.webp" type="image/webp" />
  <img src="/images/hero.jpg" alt="Hero" loading="lazy" />
</picture>
// hero.avif: 180KB (85% smaller)
// hero.webp: 240KB (80% smaller)
```

**Next.js Image Optimization**:
```javascript
// BEFORE
<img src="/hero.jpg" alt="Hero" />

// AFTER (automatic optimization)
import Image from 'next/image';

<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority // Load immediately for above-fold images
  placeholder="blur" // Show blur while loading
  blurDataURL="data:image/..." // Inline blur placeholder
/>
// Automatically serves WebP/AVIF based on browser support
```

#### 5.2. Lazy Loading

```javascript
// BEFORE (all images load immediately)
<div className="gallery">
  {images.map(img => (
    <img key={img.id} src={img.url} alt={img.title} />
  ))}
</div>
// Result: 50 images load on page load (slow)

// AFTER (native lazy loading)
<div className="gallery">
  {images.map(img => (
    <img
      key={img.id}
      src={img.url}
      alt={img.title}
      loading="lazy" // Native browser lazy loading
    />
  ))}
</div>
// Result: Only visible images load initially
// Performance: 85% fewer initial network requests
```

#### 5.3. Responsive Images

```javascript
// BEFORE (serves same large image to all devices)
<img src="/hero-2400w.jpg" alt="Hero" />
// Mobile: Downloads 2.4MB image for 375px screen

// AFTER (responsive srcset)
<img
  src="/hero-800w.jpg"
  srcset="
    /hero-400w.jpg 400w,
    /hero-800w.jpg 800w,
    /hero-1200w.jpg 1200w,
    /hero-2400w.jpg 2400w
  "
  sizes="
    (max-width: 600px) 400px,
    (max-width: 900px) 800px,
    (max-width: 1200px) 1200px,
    2400px
  "
  alt="Hero"
/>
// Mobile: Downloads 120KB image for 375px screen
// Performance: 95% smaller download on mobile
```

### 6. Asset Optimization

#### 6.1. Font Loading Strategy

```css
/* BEFORE (blocks rendering) */
@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');

/* AFTER (optimized loading) */
/* Use font-display: swap to show fallback text immediately */
@font-face {
  font-family: 'Roboto';
  src: url('/fonts/roboto.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: swap; /* Show text immediately with fallback font */
}

/* Preload critical fonts in HTML */
<link rel="preload" href="/fonts/roboto.woff2" as="font" type="font/woff2" crossorigin>
```

**Variable Fonts** (single file for multiple weights):
```css
/* BEFORE (multiple files) */
/* roboto-regular.woff2: 50KB */
/* roboto-bold.woff2: 52KB */
/* roboto-light.woff2: 48KB */
/* Total: 150KB */

/* AFTER (variable font) */
@font-face {
  font-family: 'Roboto';
  src: url('/fonts/roboto-variable.woff2') format('woff2-variations');
  font-weight: 300 700; /* Supports all weights from 300-700 */
}
/* roboto-variable.woff2: 75KB */
/* Savings: 50% smaller */
```

#### 6.2. Critical CSS

```html
<!-- BEFORE (blocks rendering until full CSS loads) -->
<link rel="stylesheet" href="/styles/main.css"> <!-- 250KB -->

<!-- AFTER (inline critical CSS, defer non-critical) -->
<style>
  /* Inline critical above-the-fold CSS (< 14KB) */
  .header { ... }
  .hero { ... }
  .nav { ... }
</style>

<!-- Defer non-critical CSS -->
<link rel="preload" href="/styles/main.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="/styles/main.css"></noscript>

<!-- Or use media query trick -->
<link rel="stylesheet" href="/styles/main.css" media="print" onload="this.media='all'">
```

#### 6.3. JavaScript Defer/Async

```html
<!-- BEFORE (blocks HTML parsing) -->
<script src="/js/analytics.js"></script>
<script src="/js/chat-widget.js"></script>
<script src="/js/app.js"></script>

<!-- AFTER (non-blocking) -->
<!-- async: Download in parallel, execute as soon as ready (order not guaranteed) -->
<script src="/js/analytics.js" async></script>
<script src="/js/chat-widget.js" async></script>

<!-- defer: Download in parallel, execute after HTML parsed (order guaranteed) -->
<script src="/js/app.js" defer></script>

<!-- Performance: Eliminates script blocking time -->
```

### 7. Caching and Service Workers

**Service Worker for Offline Support**:
```javascript
// sw.js
const CACHE_NAME = 'app-v1';
const urlsToCache = [
  '/',
  '/styles/main.css',
  '/js/app.js',
  '/images/logo.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      // Return cached version or fetch from network
      return response || fetch(event.request);
    })
  );
});

// Register in app
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js');
}
```

### 8. Web Vitals Optimization

**Optimize LCP (Largest Contentful Paint < 2.5s)**:
- Preload critical resources: `<link rel="preload" href="hero.jpg" as="image">`
- Use CDN for static assets
- Optimize server response time (TTFB < 600ms)
- Optimize images (modern formats, compression)

**Optimize FID/INP (First Input Delay / Interaction to Next Paint < 200ms)**:
- Reduce JavaScript execution time
- Break up long tasks (yield to main thread)
- Use web workers for heavy computation
- Debounce/throttle event handlers

**Optimize CLS (Cumulative Layout Shift < 0.1)**:
- Set explicit width/height for images and videos
- Reserve space for dynamic content
- Avoid inserting content above existing content
- Use CSS `aspect-ratio` for responsive media

```css
/* Prevent CLS for images */
img {
  width: 100%;
  height: auto;
  aspect-ratio: 16 / 9; /* Reserve space before image loads */
}
```

## Output Format

```markdown
# Frontend Optimization Report: [Context]

**Optimization Date**: [Date]
**Framework**: [React/Vue/Angular version]
**Build Tool**: [Webpack/Vite/Next.js version]
**Target Pages**: [List of pages]

## Executive Summary

[Summary of findings and optimizations]

## Baseline Metrics

### Lighthouse Scores (Before)

| Page | Performance | Accessibility | Best Practices | SEO |
|------|-------------|---------------|----------------|-----|
| Home | 62 | 88 | 79 | 92 |
| Dashboard | 48 | 91 | 75 | 89 |
| Profile | 55 | 90 | 82 | 91 |

### Web Vitals (Before)

| Page | LCP | FID | CLS | TTFB |
|------|-----|-----|-----|------|
| Home | 4.2s | 180ms | 0.18 | 950ms |
| Dashboard | 5.8s | 320ms | 0.25 | 1200ms |

### Bundle Sizes (Before)

| Bundle | Size (gzipped) | Percentage |
|--------|----------------|------------|
| main.js | 850KB | 68% |
| vendor.js | 320KB | 25% |
| styles.css | 85KB | 7% |
| **Total** | **1.25MB** | **100%** |

## Optimizations Implemented

### 1. Implemented Code Splitting

**Before**: Single 850KB main bundle
**After**: Initial 180KB + route chunks (120KB, 95KB, 85KB)

**Impact**: 79% smaller initial bundle

### 2. Replaced Heavy Dependencies

- Moment.js (232KB) → date-fns (12KB) = 94.8% smaller
- Lodash (70KB) → lodash-es tree-shakeable (2KB used) = 97.1% smaller
- Total savings: 288KB

### 3. Implemented Virtual Scrolling

**User List (10,000 items)**:
- Before: 2,500ms initial render, 10,000 DOM nodes
- After: 45ms initial render, ~20 visible DOM nodes
- **Improvement**: 98% faster

### 4. Optimized Images

**Hero Image**:
- Before: hero.jpg (1.2MB)
- After: hero.avif (180KB)
- **Savings**: 85%

**Implemented**:
- Modern formats (WebP, AVIF)
- Lazy loading for below-fold images
- Responsive srcset for different screen sizes

### 5. Optimized Rendering with React.memo

**Product Grid (500 items)**:
- Before: All 500 components re-render on filter change
- After: Only filtered subset re-renders (~50 items)
- **Improvement**: 90% fewer re-renders

## Results Summary

### Lighthouse Scores (After)

| Page | Performance | Accessibility | Best Practices | SEO | Improvement |
|------|-------------|---------------|----------------|-----|-------------|
| Home | 94 (+32) | 95 (+7) | 92 (+13) | 100 (+8) | +32 points |
| Dashboard | 89 (+41) | 95 (+4) | 92 (+17) | 96 (+7) | +41 points |
| Profile | 91 (+36) | 95 (+5) | 92 (+10) | 100 (+9) | +36 points |

### Web Vitals (After)

| Page | LCP | FID | CLS | TTFB | Improvement |
|------|-----|-----|-----|------|-------------|
| Home | 1.8s | 45ms | 0.02 | 320ms | 57% faster LCP |
| Dashboard | 2.1s | 65ms | 0.04 | 450ms | 64% faster LCP |

### Bundle Sizes (After)

| Bundle | Size (gzipped) | Change |
|--------|----------------|--------|
| main.js | 180KB | -79% |
| vendor-react.js | 95KB | New |
| vendor-ui.js | 85KB | New |
| styles.css | 45KB | -47% |
| **Total Initial** | **405KB** | **-68%** |

### Load Time Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Initial Bundle Load | 3.8s | 1.2s | 68% faster |
| Time to Interactive | 6.5s | 2.3s | 65% faster |
| First Contentful Paint | 2.1s | 0.8s | 62% faster |
| Largest Contentful Paint | 4.2s | 1.8s | 57% faster |

## Trade-offs and Considerations

**Code Splitting**:
- **Benefit**: 68% smaller initial bundle
- **Trade-off**: Additional network requests for route chunks
- **Mitigation**: Chunks are cached, prefetch likely routes

**Image Format Optimization**:
- **Benefit**: 85% smaller images
- **Trade-off**: Build step complexity (convert to AVIF/WebP)
- **Fallback**: JPEG fallback for older browsers

## Monitoring Recommendations

1. **Real User Monitoring** for Web Vitals
2. **Lighthouse CI** in pull request checks
3. **Bundle size tracking** in CI/CD
4. **Performance budgets** (e.g., initial bundle < 500KB)

## Next Steps

1. Implement service worker for offline support
2. Add resource hints (prefetch, preconnect)
3. Consider migrating to Next.js for automatic optimizations
4. Implement CDN for static assets

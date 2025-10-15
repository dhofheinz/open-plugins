# Accessibility Review

Performs comprehensive accessibility (a11y) audit focusing on WCAG compliance, screen reader compatibility, keyboard navigation, and inclusive design principles.

## Parameters

**Received from router**: `$ARGUMENTS` (after removing 'accessibility' operation)

Expected format: `scope:"review-scope" [depth:"quick|standard|deep"] [level:"A|AA|AAA"]`

## Workflow

### 1. Parse Parameters

Extract from $ARGUMENTS:
- **scope**: What to review (required) - components, pages, features
- **depth**: Review thoroughness (default: "standard")
- **level**: WCAG compliance level (default: "AA")

## WCAG Compliance Levels

- **Level A**: Minimum accessibility (basic compliance)
- **Level AA**: Standard accessibility (recommended target)
- **Level AAA**: Enhanced accessibility (gold standard)

### 2. Gather Context

**Identify UI Components**:
```bash
# Find frontend components
find . -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" | head -20

# Check for accessibility tooling
cat package.json | grep -E "axe|pa11y|lighthouse|eslint-plugin-jsx-a11y"

# Look for ARIA usage
grep -r "aria-" --include="*.tsx" --include="*.jsx" --include="*.html" | head -20

# Check for role attributes
grep -r 'role=' --include="*.tsx" --include="*.jsx" --include="*.html" | head -20
```

### 3. Semantic HTML Review

**Proper HTML Structure**:
- [ ] Semantic HTML elements used (`<header>`, `<nav>`, `<main>`, `<footer>`, `<article>`, `<section>`)
- [ ] Headings in logical order (h1 → h2 → h3, no skipping)
- [ ] Lists use `<ul>`, `<ol>`, `<dl>` appropriately
- [ ] Tables use `<table>`, `<th>`, `<caption>` properly
- [ ] Forms use `<form>`, `<label>`, `<fieldset>`, `<legend>`
- [ ] Buttons use `<button>` (not styled divs)
- [ ] Links use `<a>` with href attribute

**Document Structure**:
- [ ] Single `<h1>` per page describing main content
- [ ] Landmark regions defined (`<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>`)
- [ ] Skip to main content link present
- [ ] Page has meaningful `<title>`
- [ ] Language attribute on `<html>` element

**Code Examples - Semantic HTML**:

```html
<!-- ❌ BAD: Non-semantic markup -->
<div class="header">
  <div class="nav">
    <div class="nav-item" onclick="navigate('/home')">Home</div>
    <div class="nav-item" onclick="navigate('/about')">About</div>
  </div>
</div>
<div class="main-content">
  <div class="title">Welcome</div>
  <div class="text">Content here</div>
</div>

<!-- ✅ GOOD: Semantic HTML -->
<header>
  <nav aria-label="Main navigation">
    <ul>
      <li><a href="/home">Home</a></li>
      <li><a href="/about">About</a></li>
    </ul>
  </nav>
</header>
<main>
  <h1>Welcome</h1>
  <p>Content here</p>
</main>
```

```html
<!-- ❌ BAD: Incorrect heading hierarchy -->
<h1>Main Title</h1>
<h3>Subsection</h3> <!-- Skipped h2! -->
<h2>Another Section</h2> <!-- Wrong order! -->

<!-- ✅ GOOD: Logical heading order -->
<h1>Main Title</h1>
<h2>Section</h2>
<h3>Subsection</h3>
<h2>Another Section</h2>
<h3>Another Subsection</h3>
```

### 4. ARIA (Accessible Rich Internet Applications)

**ARIA Attributes**:
- [ ] ARIA used only when semantic HTML insufficient
- [ ] ARIA roles appropriate and correct
- [ ] ARIA properties accurately reflect state
- [ ] ARIA labels provide meaningful descriptions
- [ ] Dynamic content changes announced

**Common ARIA Patterns**:
- [ ] Buttons: `role="button"` with `aria-pressed` for toggles
- [ ] Dialogs: `role="dialog"`, `aria-modal="true"`, `aria-labelledby`
- [ ] Tabs: `role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-selected`
- [ ] Menus: `role="menu"`, `role="menuitem"`, `aria-haspopup`
- [ ] Alerts: `role="alert"` or `aria-live="assertive"`
- [ ] Loading: `aria-busy="true"`, `aria-live="polite"`

**ARIA Best Practices**:
- [ ] First rule of ARIA: Don't use ARIA (prefer semantic HTML)
- [ ] ARIA doesn't change behavior, only semantics
- [ ] ARIA attributes are valid and supported
- [ ] Required ARIA attributes present
- [ ] ARIA properties reflect current state

**Code Examples - ARIA**:

```tsx
// ❌ BAD: Div as button without proper ARIA
<div onClick={handleClick} className="button">
  Click me
</div>

// ✅ GOOD: Proper button element (no ARIA needed)
<button onClick={handleClick}>
  Click me
</button>

// ✅ ACCEPTABLE: Div with complete button semantics
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => e.key === 'Enter' && handleClick()}
  aria-label="Click me"
>
  Click me
</div>
```

```tsx
// ❌ BAD: No ARIA for custom dropdown
<div className="dropdown">
  <div onClick={toggle}>Menu</div>
  {isOpen && (
    <div className="menu">
      <div onClick={handleOption1}>Option 1</div>
      <div onClick={handleOption2}>Option 2</div>
    </div>
  )}
</div>

// ✅ GOOD: Proper ARIA for dropdown
<div className="dropdown">
  <button
    aria-haspopup="true"
    aria-expanded={isOpen}
    onClick={toggle}
  >
    Menu
  </button>
  {isOpen && (
    <ul role="menu">
      <li role="menuitem">
        <button onClick={handleOption1}>Option 1</button>
      </li>
      <li role="menuitem">
        <button onClick={handleOption2}>Option 2</button>
      </li>
    </ul>
  )}
</div>
```

```tsx
// ❌ BAD: Loading state not announced
{isLoading && <div className="spinner">Loading...</div>}

// ✅ GOOD: Loading state announced to screen readers
{isLoading && (
  <div role="status" aria-live="polite">
    <span className="spinner" aria-hidden="true"></span>
    <span className="sr-only">Loading...</span>
  </div>
)}
```

### 5. Keyboard Navigation

**Keyboard Accessibility**:
- [ ] All interactive elements keyboard accessible
- [ ] Tab order is logical and follows visual order
- [ ] Focus indicators visible and clear
- [ ] No keyboard traps (can always tab away)
- [ ] Skip links for keyboard users
- [ ] Shortcuts don't conflict with browser/screen reader
- [ ] Custom controls have keyboard support

**Keyboard Interactions**:
- [ ] Enter/Space activates buttons and links
- [ ] Arrow keys navigate lists and menus
- [ ] Escape closes dialogs and menus
- [ ] Tab moves to next element
- [ ] Shift+Tab moves to previous element
- [ ] Home/End navigate to start/end

**Focus Management**:
- [ ] Focus visible (no `outline: none` without alternative)
- [ ] Focus moved appropriately (dialogs, route changes)
- [ ] Focus restored when closing dialogs
- [ ] Focus not lost during dynamic updates
- [ ] Focus indicator meets contrast requirements (3:1)

**Code Examples - Keyboard Navigation**:

```tsx
// ❌ BAD: No keyboard support for custom control
<div onClick={handleClick} className="custom-button">
  Click me
</div>

// ✅ GOOD: Full keyboard support
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleClick();
    }
  }}
  className="custom-button"
>
  Click me
</div>
```

```css
/* ❌ BAD: Removed focus indicator */
*:focus {
  outline: none; /* Never do this without alternative! */
}

/* ✅ GOOD: Enhanced focus indicator */
*:focus {
  outline: 2px solid #4A90E2;
  outline-offset: 2px;
}

/* ✅ BETTER: Visible focus, hidden for mouse users */
*:focus-visible {
  outline: 2px solid #4A90E2;
  outline-offset: 2px;
}
```

```tsx
// ❌ BAD: Dialog doesn't trap focus
function Dialog({ isOpen, onClose, children }) {
  if (!isOpen) return null;

  return (
    <div className="dialog">
      <button onClick={onClose}>Close</button>
      {children}
    </div>
  );
}

// ✅ GOOD: Dialog with focus trap
function Dialog({ isOpen, onClose, children }) {
  const dialogRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
      // Focus first focusable element
      const firstFocusable = dialogRef.current?.querySelector(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      (firstFocusable as HTMLElement)?.focus();
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div
      ref={dialogRef}
      role="dialog"
      aria-modal="true"
      onKeyDown={(e) => e.key === 'Escape' && onClose()}
    >
      <button onClick={onClose}>Close</button>
      {children}
    </div>
  );
}
```

### 6. Screen Reader Compatibility

**Screen Reader Considerations**:
- [ ] All content accessible to screen readers
- [ ] Images have alt text (or marked decorative)
- [ ] Form inputs have associated labels
- [ ] Error messages announced
- [ ] Dynamic content changes announced
- [ ] Hidden content not read by screen readers
- [ ] Reading order matches visual order

**Text Alternatives**:
- [ ] Images have descriptive alt text
- [ ] Decorative images have `alt=""` or `aria-hidden="true"`
- [ ] Icon buttons have accessible names
- [ ] SVG graphics have `<title>` and `<desc>`
- [ ] Video/audio has captions and transcripts
- [ ] Complex images have long descriptions

**Form Accessibility**:
- [ ] Labels associated with inputs (`<label for="...">` or wrapping)
- [ ] Required fields indicated (`required` or `aria-required`)
- [ ] Error messages associated with fields (`aria-describedby`)
- [ ] Fieldsets group related inputs
- [ ] Form validation errors announced
- [ ] Help text associated with inputs

**Code Examples - Screen Readers**:

```tsx
// ❌ BAD: No alt text
<img src="/logo.png" />

// ✅ GOOD: Descriptive alt text
<img src="/logo.png" alt="Company Logo" />

// ✅ GOOD: Decorative image
<img src="/decorative-border.png" alt="" />
<img src="/background.png" aria-hidden="true" />
```

```tsx
// ❌ BAD: Icon button without accessible name
<button onClick={handleDelete}>
  <TrashIcon />
</button>

// ✅ GOOD: Icon button with accessible name
<button onClick={handleDelete} aria-label="Delete item">
  <TrashIcon aria-hidden="true" />
</button>

// ✅ ALSO GOOD: Visually hidden text
<button onClick={handleDelete}>
  <TrashIcon aria-hidden="true" />
  <span className="sr-only">Delete item</span>
</button>
```

```tsx
// ❌ BAD: Form without labels
<input type="text" placeholder="Enter your name" />

// ✅ GOOD: Properly labeled form field
<label htmlFor="name">Name</label>
<input type="text" id="name" placeholder="Enter your name" />

// ✅ ALSO GOOD: Wrapping label
<label>
  Name
  <input type="text" placeholder="Enter your name" />
</label>
```

```tsx
// ❌ BAD: Error not associated with field
<input type="email" id="email" />
{error && <div className="error">Invalid email</div>}

// ✅ GOOD: Error associated with field
<input
  type="email"
  id="email"
  aria-invalid={!!error}
  aria-describedby={error ? "email-error" : undefined}
/>
{error && (
  <div id="email-error" className="error" role="alert">
    Invalid email
  </div>
)}
```

### 7. Color and Contrast

**Color Contrast** (WCAG AA):
- [ ] Normal text: 4.5:1 contrast ratio minimum
- [ ] Large text (18pt+ or 14pt+ bold): 3:1 minimum
- [ ] UI components: 3:1 contrast with adjacent colors
- [ ] Focus indicators: 3:1 contrast with background
- [ ] WCAG AAA: 7:1 for normal text, 4.5:1 for large text

**Color Usage**:
- [ ] Information not conveyed by color alone
- [ ] Color blind friendly palette
- [ ] Links distinguishable without color (underline, icon)
- [ ] Form validation errors not color-only
- [ ] Charts/graphs have patterns or labels

**Code Examples - Color and Contrast**:

```tsx
// ❌ BAD: Color only to indicate error
<input
  type="text"
  style={{ borderColor: hasError ? 'red' : 'gray' }}
/>

// ✅ GOOD: Multiple indicators for error
<input
  type="text"
  aria-invalid={hasError}
  aria-describedby={hasError ? "error-message" : undefined}
  style={{
    borderColor: hasError ? 'red' : 'gray',
    borderWidth: hasError ? '2px' : '1px'
  }}
/>
{hasError && (
  <div id="error-message" role="alert">
    <ErrorIcon aria-hidden="true" />
    This field is required
  </div>
)}
```

```tsx
// ❌ BAD: Link only differentiated by color
<a href="/more" style={{ color: 'blue', textDecoration: 'none' }}>
  Read more
</a>

// ✅ GOOD: Link with underline
<a href="/more" style={{ color: 'blue', textDecoration: 'underline' }}>
  Read more
</a>

// ✅ ALSO GOOD: Link with icon
<a href="/more" style={{ color: 'blue' }}>
  Read more <ArrowIcon aria-hidden="true" />
</a>
```

### 8. Responsive and Adaptive Design

**Viewport and Zoom**:
- [ ] Content adapts to viewport size
- [ ] Text can be resized to 200% without loss of functionality
- [ ] No horizontal scrolling at 320px width
- [ ] Touch targets at least 44x44 pixels (mobile)
- [ ] Pinch-to-zoom not disabled

**Media Queries**:
- [ ] Reduced motion preferences respected
- [ ] High contrast mode supported
- [ ] Dark mode accessible
- [ ] Print styles appropriate

**Code Examples - Responsive**:

```css
/* ❌ BAD: Disables zoom */
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">

/* ✅ GOOD: Allows zoom */
<meta name="viewport" content="width=device-width, initial-scale=1">
```

```css
/* ✅ GOOD: Respect reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

```tsx
// ✅ GOOD: Touch targets sized appropriately
<button style={{
  minWidth: '44px',
  minHeight: '44px',
  padding: '12px'
}}>
  Click me
</button>
```

### 9. Multimedia Accessibility

**Video Accessibility**:
- [ ] Captions for all audio content
- [ ] Audio descriptions for visual content
- [ ] Transcript provided
- [ ] Controls keyboard accessible
- [ ] Auto-play disabled or user-controlled

**Audio Accessibility**:
- [ ] Transcripts provided
- [ ] Visual indicators for audio cues
- [ ] User can control volume and playback

**Code Examples - Multimedia**:

```html
<!-- ✅ GOOD: Video with captions and transcript -->
<video controls>
  <source src="video.mp4" type="video/mp4">
  <track kind="captions" src="captions.vtt" srclang="en" label="English">
  <track kind="descriptions" src="descriptions.vtt" srclang="en" label="English">
</video>
<details>
  <summary>Video Transcript</summary>
  <p>[Full transcript here]</p>
</details>
```

### 10. Automated Testing

**Run Accessibility Audits**:
```bash
# Lighthouse audit
npx lighthouse https://your-site.com --only-categories=accessibility --view

# axe-core testing
npm install --save-dev @axe-core/cli
npx axe https://your-site.com

# pa11y testing
npm install --save-dev pa11y
npx pa11y https://your-site.com

# ESLint accessibility plugin (React)
npm install --save-dev eslint-plugin-jsx-a11y
```

**Manual Testing**:
- [ ] Test with keyboard only (no mouse)
- [ ] Test with screen reader (NVDA, JAWS, VoiceOver)
- [ ] Test with browser zoom at 200%
- [ ] Test in high contrast mode
- [ ] Test with CSS disabled
- [ ] Test on mobile devices

## Review Depth Implementation

**Quick Depth** (10-15 min):
- Semantic HTML check
- Alt text verification
- Form label check
- Keyboard navigation test
- Automated audit (Lighthouse)

**Standard Depth** (30-45 min):
- Complete WCAG AA checklist
- ARIA usage review
- Keyboard navigation thorough test
- Focus management review
- Color contrast check
- Screen reader spot checks

**Deep Depth** (60-90+ min):
- Complete WCAG AAA checklist
- Comprehensive screen reader testing
- Keyboard-only navigation of entire scope
- Color blindness simulation
- Reduced motion testing
- High contrast mode testing
- Mobile accessibility testing
- Automated testing suite

## Output Format

```markdown
# Accessibility Review: [Scope]

## Executive Summary

**Reviewed**: [What was reviewed]
**Depth**: [Quick|Standard|Deep]
**WCAG Level Target**: [A|AA|AAA]
**Accessibility Rating**: [Excellent|Good|Needs Work|Poor]

### Overall Assessment
**[Compliant|Partially Compliant|Non-Compliant] with WCAG [Level]**

[Brief explanation]

### Priority Actions
1. [Critical a11y issue 1]
2. [Critical a11y issue 2]

---

## Critical Issues 🚨

**[Must fix for basic accessibility]**

### [Issue 1 Title]
**File**: `path/to/component.tsx:42`
**WCAG Criterion**: [X.X.X - Criterion Name - Level A/AA/AAA]
**Issue**: [Description of accessibility barrier]
**Impact**: [How this affects users]
**Affected Users**: [Screen reader users, keyboard users, low vision users, etc.]
**Fix**:

```tsx
// Current (inaccessible)
[problematic code]

// Accessible implementation
[fixed code]
```

**Testing**: [How to verify the fix]

[Repeat for each critical issue]

---

## High Priority Issues ⚠️

**[Should fix for good accessibility]**

[Similar format for high priority issues]

---

## Medium Priority Issues ℹ️

**[Consider fixing for enhanced accessibility]**

[Similar format for medium priority issues]

---

## Low Priority Issues 💡

**[Nice to have for optimal accessibility]**

[Similar format for low priority issues]

---

## Accessibility Strengths ✅

- ✅ [Good practice 1 with examples]
- ✅ [Good practice 2 with examples]
- ✅ [Good practice 3 with examples]

---

## WCAG 2.1 Compliance Summary

### Level A (Minimum)

| Criterion | Status | Notes |
|-----------|--------|-------|
| 1.1.1 Non-text Content | ✅ / ⚠️ / ❌ | [Details] |
| 1.3.1 Info and Relationships | ✅ / ⚠️ / ❌ | [Details] |
| 1.3.2 Meaningful Sequence | ✅ / ⚠️ / ❌ | [Details] |
| 2.1.1 Keyboard | ✅ / ⚠️ / ❌ | [Details] |
| 2.1.2 No Keyboard Trap | ✅ / ⚠️ / ❌ | [Details] |
| 2.4.1 Bypass Blocks | ✅ / ⚠️ / ❌ | [Details] |
| 3.1.1 Language of Page | ✅ / ⚠️ / ❌ | [Details] |
| 4.1.1 Parsing | ✅ / ⚠️ / ❌ | [Details] |
| 4.1.2 Name, Role, Value | ✅ / ⚠️ / ❌ | [Details] |

### Level AA (Recommended)

| Criterion | Status | Notes |
|-----------|--------|-------|
| 1.4.3 Contrast (Minimum) | ✅ / ⚠️ / ❌ | [Details] |
| 1.4.5 Images of Text | ✅ / ⚠️ / ❌ | [Details] |
| 2.4.5 Multiple Ways | ✅ / ⚠️ / ❌ | [Details] |
| 2.4.6 Headings and Labels | ✅ / ⚠️ / ❌ | [Details] |
| 2.4.7 Focus Visible | ✅ / ⚠️ / ❌ | [Details] |
| 3.1.2 Language of Parts | ✅ / ⚠️ / ❌ | [Details] |
| 3.2.3 Consistent Navigation | ✅ / ⚠️ / ❌ | [Details] |
| 3.3.3 Error Suggestion | ✅ / ⚠️ / ❌ | [Details] |
| 3.3.4 Error Prevention (Legal) | ✅ / ⚠️ / ❌ | [Details] |

### Level AAA (Enhanced) - Optional

[If deep review includes AAA]

---

## Detailed Accessibility Analysis

### 🏗️ Semantic HTML

**Overall**: [Excellent|Good|Needs Work]

**Strengths**:
- ✅ [Well-structured areas]

**Issues**:
- ⚠️ [Semantic HTML issues with file references]

**Heading Structure**:
```
h1: [Page title]
  h2: [Section 1]
    h3: [Subsection]
  h2: [Section 2]
```

### 🎯 ARIA Usage

**Overall**: [Appropriate|Overused|Underused]

**Proper ARIA**:
- ✅ [Good ARIA usage examples]

**ARIA Issues**:
- ⚠️ [ARIA problems with file references]

### ⌨️ Keyboard Navigation

**Overall**: [Fully Accessible|Partially Accessible|Not Accessible]

**Tab Order**: [Logical|Needs Work]

**Keyboard Support**:
- ✅ [Components with full keyboard support]
- ⚠️ [Components with keyboard issues]

**Focus Management**: [Good|Needs Improvement]

### 📢 Screen Reader Compatibility

**Tested with**: [NVDA|JAWS|VoiceOver|Narrator]

**Screen Reader Experience**: [Excellent|Good|Poor]

**Issues Found**:
- ⚠️ [Screen reader issues]

**Missing Alternatives**:
- ⚠️ [Missing alt text, labels, etc.]

### 🎨 Color and Contrast

**Contrast Ratio Analysis**:

| Element | Foreground | Background | Ratio | WCAG AA | WCAG AAA |
|---------|-----------|------------|-------|---------|----------|
| Body text | [Color] | [Color] | [X:1] | ✅ / ❌ | ✅ / ❌ |
| Links | [Color] | [Color] | [X:1] | ✅ / ❌ | ✅ / ❌ |
| Buttons | [Color] | [Color] | [X:1] | ✅ / ❌ | ✅ / ❌ |

**Color Usage**: [Accessible|Issues Found]

### 📱 Responsive and Mobile

**Mobile Accessibility**: [Excellent|Good|Needs Work]

**Touch Target Sizes**: [Adequate|Too Small]

**Zoom Support**: [Enabled|Disabled]

---

## Testing Results

### Automated Testing

**Lighthouse Score**: [X/100]

**axe-core Results**:
- Critical issues: [X]
- Serious issues: [X]
- Moderate issues: [X]
- Minor issues: [X]

### Manual Testing

**Keyboard-Only Navigation**: [Pass|Fail] - [Details]

**Screen Reader Testing**: [Pass|Fail] - [Details]

**Zoom to 200%**: [Pass|Fail] - [Details]

**High Contrast Mode**: [Pass|Fail] - [Details]

---

## Recommendations

### Immediate (This Week)
- [ ] [Critical fix 1]
- [ ] [Critical fix 2]

### Short-term (This Month)
- [ ] [High priority fix 1]
- [ ] [High priority fix 2]

### Long-term (This Quarter)
- [ ] [Strategic improvement 1]
- [ ] [Strategic improvement 2]

---

## Resources

**Testing Tools**:
- Lighthouse (Chrome DevTools)
- axe DevTools (browser extension)
- WAVE (browser extension)
- Screen reader (NVDA, JAWS, VoiceOver)

**Guidelines**:
- WCAG 2.1: https://www.w3.org/WAI/WCAG21/quickref/
- ARIA Authoring Practices: https://www.w3.org/WAI/ARIA/apg/

---

## Review Metadata

- **Reviewer**: 10x Fullstack Engineer (Accessibility Focus)
- **Review Date**: [Date]
- **WCAG Level**: [A|AA|AAA]
- **A11y Issues**: Critical: X, High: X, Medium: X, Low: X
- **Compliance Status**: [Compliant|Partially Compliant|Non-Compliant]
```

## Agent Invocation

This operation MUST leverage the **10x-fullstack-engineer** agent with accessibility expertise.

## Best Practices

1. **Semantic HTML First**: Use native elements before ARIA
2. **Test with Real Users**: Automated tools catch ~30-40% of issues
3. **Keyboard First**: If keyboard works, most other things will follow
4. **Don't Assume**: Test with actual assistive technology
5. **Progressive Enhancement**: Start accessible, add features
6. **Inclusive Design**: Consider all users from the beginning

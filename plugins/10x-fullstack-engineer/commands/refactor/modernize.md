# Legacy Code Modernization Operation

Update legacy code patterns to modern JavaScript/TypeScript standards and best practices.

## Parameters

**Received from $ARGUMENTS**: All arguments after "modernize"

**Expected format**:
```
scope:"<path>" targets:"<target1,target2>" [compatibility:"<version>"]
```

**Parameter definitions**:
- `scope` (REQUIRED): Path to modernize (e.g., "src/legacy/", "utils/old-helpers.js")
- `targets` (REQUIRED): Comma-separated modernization targets
  - `callbacks-to-async` - Convert callbacks to async/await
  - `var-to-const` - Replace var with const/let
  - `prototypes-to-classes` - Convert prototypes to ES6 classes
  - `commonjs-to-esm` - Convert CommonJS to ES modules
  - `jquery-to-vanilla` - Replace jQuery with vanilla JS
  - `classes-to-hooks` - Convert React class components to hooks
  - `legacy-api` - Update deprecated API usage
- `compatibility` (OPTIONAL): Target environment (e.g., "node14+", "es2020", "modern-browsers")

## Workflow

### 1. Analyze Legacy Patterns

Identify legacy code to modernize:

```bash
# Find var usage
grep -r "var " <scope> --include="*.js" --include="*.ts"

# Find callback patterns
grep -r "function.*callback" <scope>

# Find prototype usage
grep -r ".prototype" <scope>

# Find require() usage
grep -r "require\(" <scope>

# Find jQuery usage
grep -r "\$\(" <scope>
```

### 2. Target-Specific Modernization

## Modernization Examples

### Target 1: Callbacks to Async/Await

**When to modernize**:
- Callback hell (deeply nested callbacks)
- Error handling is scattered
- Readability suffers
- Modern runtime supports async/await

**Before** (Callback hell):
```javascript
// database.js
function getUser(userId, callback) {
  db.query('SELECT * FROM users WHERE id = ?', [userId], function(err, user) {
    if (err) {
      return callback(err);
    }

    db.query('SELECT * FROM posts WHERE author_id = ?', [userId], function(err, posts) {
      if (err) {
        return callback(err);
      }

      db.query('SELECT * FROM comments WHERE user_id = ?', [userId], function(err, comments) {
        if (err) {
          return callback(err);
        }

        callback(null, {
          user: user,
          posts: posts,
          comments: comments
        });
      });
    });
  });
}

// Usage
getUser(123, function(err, data) {
  if (err) {
    console.error('Error:', err);
    return;
  }

  console.log('User:', data.user);
  console.log('Posts:', data.posts);
  console.log('Comments:', data.comments);
});
```

**After** (Async/await - Clean and readable):
```typescript
// database.ts
import { query } from './db';

interface User {
  id: number;
  name: string;
  email: string;
}

interface Post {
  id: number;
  title: string;
  content: string;
  authorId: number;
}

interface Comment {
  id: number;
  content: string;
  userId: number;
}

interface UserWithContent {
  user: User;
  posts: Post[];
  comments: Comment[];
}

async function getUser(userId: number): Promise<UserWithContent> {
  // Parallel execution for better performance
  const [user, posts, comments] = await Promise.all([
    query<User>('SELECT * FROM users WHERE id = ?', [userId]),
    query<Post[]>('SELECT * FROM posts WHERE author_id = ?', [userId]),
    query<Comment[]>('SELECT * FROM comments WHERE user_id = ?', [userId])
  ]);

  return { user, posts, comments };
}

// Usage - Much cleaner
try {
  const data = await getUser(123);
  console.log('User:', data.user);
  console.log('Posts:', data.posts);
  console.log('Comments:', data.comments);
} catch (error) {
  console.error('Error:', error);
}
```

**More callback conversions**:

```javascript
// Before: fs callbacks
const fs = require('fs');

fs.readFile('config.json', 'utf8', function(err, data) {
  if (err) {
    console.error(err);
    return;
  }

  const config = JSON.parse(data);
  fs.writeFile('output.json', JSON.stringify(config), function(err) {
    if (err) {
      console.error(err);
      return;
    }
    console.log('Done');
  });
});

// After: fs promises
import { readFile, writeFile } from 'fs/promises';

try {
  const data = await readFile('config.json', 'utf8');
  const config = JSON.parse(data);
  await writeFile('output.json', JSON.stringify(config));
  console.log('Done');
} catch (error) {
  console.error(error);
}
```

**Improvements**:
- No callback hell: Flat, linear code
- Better error handling: Single try/catch
- Parallel execution: Promise.all() for performance
- Type safety: Full TypeScript support
- Readability: Much easier to understand

---

### Target 2: var to const/let

**When to modernize**:
- Using old var declarations
- Want block scoping
- Prevent accidental reassignment
- Modern ES6+ environment

**Before** (var - function scoped, hoisted):
```javascript
function processOrders() {
  var total = 0;
  var count = 0;

  for (var i = 0; i < orders.length; i++) {
    var order = orders[i];
    var price = order.price;
    var quantity = order.quantity;

    total += price * quantity;
    count++;
  }

  // i is still accessible here (function scoped!)
  console.log(i); // orders.length

  return { total: total, count: count };
}

// Hoisting issues
function example() {
  console.log(x); // undefined (not error)
  var x = 10;
}

// Loop issues
for (var i = 0; i < 3; i++) {
  setTimeout(function() {
    console.log(i); // Always prints 3!
  }, 100);
}
```

**After** (const/let - block scoped, not hoisted):
```typescript
function processOrders(): { total: number; count: number } {
  let total = 0;
  let count = 0;

  for (let i = 0; i < orders.length; i++) {
    const order = orders[i];
    const price = order.price;
    const quantity = order.quantity;

    total += price * quantity;
    count++;
  }

  // i is NOT accessible here (block scoped)
  // console.log(i); // Error: i is not defined

  return { total, count };
}

// No hoisting issues
function example() {
  console.log(x); // Error: Cannot access 'x' before initialization
  const x = 10;
}

// Loop fixed
for (let i = 0; i < 3; i++) {
  setTimeout(() => {
    console.log(i); // Prints 0, 1, 2 correctly
  }, 100);
}
```

**Guidelines**:
- Use `const` by default (immutable binding)
- Use `let` when reassignment needed
- Never use `var` in modern code
- Block scope prevents many bugs

---

### Target 3: Prototypes to ES6 Classes

**When to modernize**:
- Using prototype-based inheritance
- Want cleaner OOP syntax
- Better IDE support needed
- Modern JavaScript environment

**Before** (Prototype pattern):
```javascript
// Animal.js
function Animal(name, age) {
  this.name = name;
  this.age = age;
}

Animal.prototype.speak = function() {
  console.log(this.name + ' makes a sound');
};

Animal.prototype.getInfo = function() {
  return this.name + ' is ' + this.age + ' years old';
};

// Dog.js
function Dog(name, age, breed) {
  Animal.call(this, name, age);
  this.breed = breed;
}

Dog.prototype = Object.create(Animal.prototype);
Dog.prototype.constructor = Dog;

Dog.prototype.speak = function() {
  console.log(this.name + ' barks');
};

Dog.prototype.fetch = function() {
  console.log(this.name + ' fetches the ball');
};

// Usage
var dog = new Dog('Rex', 3, 'Labrador');
dog.speak(); // Rex barks
console.log(dog.getInfo()); // Rex is 3 years old
```

**After** (ES6 Classes):
```typescript
// Animal.ts
export class Animal {
  constructor(
    protected name: string,
    protected age: number
  ) {}

  speak(): void {
    console.log(`${this.name} makes a sound`);
  }

  getInfo(): string {
    return `${this.name} is ${this.age} years old`;
  }
}

// Dog.ts
export class Dog extends Animal {
  constructor(
    name: string,
    age: number,
    private breed: string
  ) {
    super(name, age);
  }

  speak(): void {
    console.log(`${this.name} barks`);
  }

  fetch(): void {
    console.log(`${this.name} fetches the ball`);
  }

  getBreed(): string {
    return this.breed;
  }
}

// Usage
const dog = new Dog('Rex', 3, 'Labrador');
dog.speak(); // Rex barks
console.log(dog.getInfo()); // Rex is 3 years old
console.log(dog.getBreed()); // Labrador
```

**Improvements**:
- Cleaner syntax: More readable
- Better inheritance: extends keyword
- Access modifiers: public, private, protected
- Type safety: Full TypeScript support
- IDE support: Better autocomplete

---

### Target 4: CommonJS to ES Modules

**When to modernize**:
- Using require() and module.exports
- Want tree-shaking benefits
- Modern bundler support
- Better static analysis

**Before** (CommonJS):
```javascript
// utils.js
const crypto = require('crypto');
const fs = require('fs');

function generateId() {
  return crypto.randomUUID();
}

function readConfig() {
  return JSON.parse(fs.readFileSync('config.json', 'utf8'));
}

module.exports = {
  generateId,
  readConfig
};

// user-service.js
const { generateId } = require('./utils');
const db = require('./database');

class UserService {
  async createUser(data) {
    const id = generateId();
    return db.users.create({ ...data, id });
  }
}

module.exports = UserService;

// index.js
const express = require('express');
const UserService = require('./user-service');

const app = express();
const userService = new UserService();

app.post('/users', async (req, res) => {
  const user = await userService.createUser(req.body);
  res.json(user);
});

module.exports = app;
```

**After** (ES Modules):
```typescript
// utils.ts
import { randomUUID } from 'crypto';
import { readFileSync } from 'fs';

export function generateId(): string {
  return randomUUID();
}

export function readConfig(): Config {
  return JSON.parse(readFileSync('config.json', 'utf8'));
}

// user-service.ts
import { generateId } from './utils.js';
import { db } from './database.js';

export class UserService {
  async createUser(data: CreateUserInput): Promise<User> {
    const id = generateId();
    return db.users.create({ ...data, id });
  }
}

// index.ts
import express from 'express';
import { UserService } from './user-service.js';

const app = express();
const userService = new UserService();

app.post('/users', async (req, res) => {
  const user = await userService.createUser(req.body);
  res.json(user);
});

export default app;
```

**Improvements**:
- Tree-shaking: Remove unused exports
- Static imports: Better bundler optimization
- Named exports: More explicit imports
- Top-level await: Possible in ES modules
- Standard: Modern JavaScript standard

---

### Target 5: jQuery to Vanilla JavaScript

**When to modernize**:
- Remove jQuery dependency
- Reduce bundle size
- Modern browsers support native APIs
- Better performance

**Before** (jQuery):
```javascript
// app.js - Heavy jQuery usage
$(document).ready(function() {
  // DOM selection
  var $button = $('#submit-button');
  var $form = $('.user-form');
  var $inputs = $form.find('input');

  // Event handling
  $button.on('click', function(e) {
    e.preventDefault();

    // Get form data
    var formData = {};
    $inputs.each(function() {
      var $input = $(this);
      formData[$input.attr('name')] = $input.val();
    });

    // AJAX request
    $.ajax({
      url: '/api/users',
      method: 'POST',
      data: JSON.stringify(formData),
      contentType: 'application/json',
      success: function(response) {
        // DOM manipulation
        var $message = $('<div>')
          .addClass('success-message')
          .text('User created successfully!');

        $form.after($message);
        $message.fadeIn().delay(3000).fadeOut();

        // Clear form
        $inputs.val('');
      },
      error: function(xhr) {
        $('.error-message').text(xhr.responseText).show();
      }
    });
  });

  // Show/hide password
  $('.toggle-password').on('click', function() {
    var $input = $(this).siblings('input');
    var type = $input.attr('type');
    $input.attr('type', type === 'password' ? 'text' : 'password');
    $(this).toggleClass('active');
  });
});
```

**After** (Vanilla JavaScript):
```typescript
// app.ts - Modern vanilla JavaScript
document.addEventListener('DOMContentLoaded', () => {
  // DOM selection - Native APIs
  const button = document.querySelector<HTMLButtonElement>('#submit-button');
  const form = document.querySelector<HTMLFormElement>('.user-form');
  const inputs = form?.querySelectorAll<HTMLInputElement>('input');

  if (!button || !form || !inputs) return;

  // Event handling - addEventListener
  button.addEventListener('click', async (e) => {
    e.preventDefault();

    // Get form data - FormData API
    const formData = new FormData(form);
    const data = Object.fromEntries(formData.entries());

    try {
      // Fetch API instead of $.ajax
      const response = await fetch('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });

      if (!response.ok) {
        throw new Error(await response.text());
      }

      const user = await response.json();

      // DOM manipulation - Native APIs
      const message = document.createElement('div');
      message.className = 'success-message';
      message.textContent = 'User created successfully!';

      form.insertAdjacentElement('afterend', message);

      // CSS animations instead of jQuery animations
      message.style.opacity = '0';
      message.style.display = 'block';

      requestAnimationFrame(() => {
        message.style.transition = 'opacity 0.3s';
        message.style.opacity = '1';

        setTimeout(() => {
          message.style.opacity = '0';
          setTimeout(() => message.remove(), 300);
        }, 3000);
      });

      // Clear form
      form.reset();

    } catch (error) {
      const errorMessage = document.querySelector('.error-message');
      if (errorMessage) {
        errorMessage.textContent = error.message;
        errorMessage.style.display = 'block';
      }
    }
  });

  // Show/hide password - Native APIs
  const toggleButtons = document.querySelectorAll<HTMLButtonElement>('.toggle-password');

  toggleButtons.forEach(toggle => {
    toggle.addEventListener('click', () => {
      const input = toggle.previousElementSibling as HTMLInputElement;
      if (!input) return;

      const type = input.type === 'password' ? 'text' : 'password';
      input.type = type;
      toggle.classList.toggle('active');
    });
  });
});
```

**Bundle size impact**:
- Before: ~30KB (jQuery minified + gzipped)
- After: ~0KB (native APIs)
- **Savings**: 30KB, faster load time

**Improvements**:
- No jQuery dependency
- Modern native APIs
- Better performance
- TypeScript support
- Smaller bundle size

---

### Target 6: React Class Components to Hooks

**When to modernize**:
- Using class components
- Want simpler code
- Better functional composition
- Modern React patterns

**Before** (Class component):
```typescript
// UserProfile.tsx
import React, { Component } from 'react';

interface Props {
  userId: string;
}

interface State {
  user: User | null;
  loading: boolean;
  error: Error | null;
}

class UserProfile extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      user: null,
      loading: true,
      error: null
    };

    this.handleRefresh = this.handleRefresh.bind(this);
  }

  componentDidMount() {
    this.loadUser();
  }

  componentDidUpdate(prevProps: Props) {
    if (prevProps.userId !== this.props.userId) {
      this.loadUser();
    }
  }

  async loadUser() {
    this.setState({ loading: true, error: null });

    try {
      const response = await fetch(`/api/users/${this.props.userId}`);
      const user = await response.json();
      this.setState({ user, loading: false });
    } catch (error) {
      this.setState({ error, loading: false });
    }
  }

  handleRefresh() {
    this.loadUser();
  }

  render() {
    const { user, loading, error } = this.state;

    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error.message}</div>;
    if (!user) return <div>User not found</div>;

    return (
      <div className="user-profile">
        <h1>{user.name}</h1>
        <p>{user.email}</p>
        <button onClick={this.handleRefresh}>Refresh</button>
      </div>
    );
  }
}

export default UserProfile;
```

**After** (Function component with hooks):
```typescript
// UserProfile.tsx
import { useState, useEffect } from 'react';

interface Props {
  userId: string;
}

export function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  // Extract to custom hook for reusability
  const loadUser = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`/api/users/${userId}`);
      const userData = await response.json();
      setUser(userData);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  };

  // Load user on mount and when userId changes
  useEffect(() => {
    loadUser();
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      <button onClick={loadUser}>Refresh</button>
    </div>
  );
}
```

**Even better with custom hook**:
```typescript
// hooks/useUser.ts
import { useState, useEffect } from 'react';

export function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const loadUser = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`/api/users/${userId}`);
      const userData = await response.json();
      setUser(userData);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUser();
  }, [userId]);

  return { user, loading, error, refresh: loadUser };
}

// UserProfile.tsx - Super clean now!
export function UserProfile({ userId }: { userId: string }) {
  const { user, loading, error, refresh } = useUser(userId);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      <button onClick={refresh}>Refresh</button>
    </div>
  );
}
```

**Improvements**:
- Less boilerplate: No constructor, bind, etc.
- Simpler: Function instead of class
- Reusability: Custom hooks
- Better composition: Hooks compose well
- Modern: Current React best practice

---

## Output Format

```markdown
# Legacy Code Modernization Report

## Targets Modernized: <target1, target2, ...>

**Scope**: <path>
**Compatibility**: <version>

## Before Modernization

**Legacy Patterns Found**:
- var declarations: <count>
- Callback functions: <count>
- Prototype usage: <count>
- CommonJS modules: <count>
- jQuery usage: <count>
- Class components: <count>

**Issues**:
- Callback hell in <count> files
- Poor error handling
- Large bundle size (jQuery dependency)
- Outdated syntax

## Modernization Performed

### Target 1: <target-name>

**Files Modified**: <count>

**Before**:
```javascript
<legacy-code>
```

**After**:
```typescript
<modern-code>
```

**Improvements**:
- <improvement 1>
- <improvement 2>

### Target 2: <target-name>

[Same structure...]

## After Modernization

**Modern Patterns**:
- const/let: <count> conversions
- Async/await: <count> conversions
- ES6 classes: <count> conversions
- ES modules: <count> conversions
- Vanilla JS: <count> jQuery removals
- Function components: <count> conversions

**Metrics**:
- Bundle size: <before>KB → <after>KB (<percentage>% reduction)
- Code quality: Significantly improved
- Maintainability: Much easier
- Performance: <improvement>

## Testing

**Tests Updated**: <count>
**All tests passing**: YES
**New tests added**: <count>

## Breaking Changes

<list-breaking-changes-or-none>

## Migration Guide

**For Consumers**:
```typescript
// Old API
<old-usage>

// New API
<new-usage>
```

## Next Steps

**Further Modernization**:
1. <next-opportunity>
2. <another-opportunity>

---

**Modernization Complete**: Codebase updated to modern standards.
```

## Error Handling

**Incompatible environment**:
```
Error: Target environment does not support <feature>

Target: <compatibility>
Required: <minimum-version>

Options:
1. Use Babel/TypeScript to transpile
2. Update target environment
3. Choose different modernization target
```

**Too many changes**:
```
Warning: Modernizing <count> files is a large change.

Recommendation: Gradual modernization
1. Start with critical paths
2. Modernize incrementally
3. Test thoroughly between changes
4. Review with team
```

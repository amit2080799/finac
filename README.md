# Finac

Personal expense tracking app with a React frontend and a Rails JSON API. Manage monthly expenses, view dashboard summaries, and (for admins) manage users and roles.

For system design, API contracts, and authorization rules, see **[architecture.md](./architecture.md)**.

## Tech stack

- **Ruby** 3.0.2 · **Rails** 7.0 · **PostgreSQL**
- **React** 19 · **React Router** 6 · **Webpacker** 5
- **Devise** (session auth) · **CanCanCan** (roles)

## Prerequisites

Install before setup:

| Tool | Version / notes |
|------|------------------|
| Ruby | 3.0.2 ([rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) recommended) |
| Bundler | 2.x (`gem install bundler`) |
| Node.js | 16+ and [Yarn](https://yarnpkg.com/) 1.x |
| PostgreSQL | 12+ running locally |

On macOS with Homebrew:

```bash
brew install postgresql@14 node yarn rbenv
brew services start postgresql@14
```

## Local setup

### 1. Clone and install dependencies

```bash
cd finac
rbenv install 3.0.2   # if needed
rbenv local 3.0.2

bundle install
yarn install
```

### 2. Database

Create the PostgreSQL database (default name: `finac` — see `config/database.yml`):

```bash
# If your OS user is not a Postgres superuser, create a role/database first:
# createuser -s finac
# createdb -O finac finac

bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

`db:seed` loads expense types, payment modes, banks, and creates a **super admin** when no users exist:

| Field | Value |
|-------|--------|
| Email | `admin@finac.local` |
| Password | `changeme123` |

Change this password after first login in production.

### 3. Start the application

You need **two processes** in development: the Rails server and the frontend bundle (Webpack).

**Terminal 1 — Rails**

```bash
bundle exec rails server
```

App URL: [http://localhost:3000](http://localhost:3000)

**Terminal 2 — JavaScript (choose one)**

```bash
# Option A: compile once (simplest)
bundle exec bin/webpack

# Option B: recompile on file changes
bundle exec bin/webpack --watch

# Option C: webpack dev server (hot reload for JS)
bundle exec bin/webpack-dev-server
```

Then open [http://localhost:3000/login](http://localhost:3000/login) and sign in with the seed credentials.

**Alternative — Foreman (Rails only)**

`bin/dev` starts only the Rails process via `Procfile.dev`. You still need Webpack running separately (Terminal 2 above) unless assets were precompiled.

### 4. Promote an existing user to admin (optional)

```bash
bundle exec rails console
```

```ruby
User.find_by(email: 'you@example.com')&.update!(role: :super_admin)
```

## Running tests

```bash
bundle exec rails test
```

## Common issues

| Problem | Fix |
|---------|-----|
| `Could not find rails` / gem errors | Run `bundle install` |
| Blank page / no React UI | Run `bin/webpack` or `bin/webpack --watch` |
| `PG::ConnectionBad` | Start PostgreSQL; check `config/database.yml` |
| `401` on API calls | Sign in at `/login`; ensure cookies are enabled |
| Webpack / Node errors | Run `yarn install`; try Node 18 LTS if React 19 fails |

## Project layout (quick reference)

```
app/javascript/finac/     # React SPA source
app/controllers/api/v1/   # JSON API
app/models/               # Domain models
config/routes.rb          # API + SPA catch-all
architecture.md           # Full architecture doc
```

## Production build (brief)

```bash
RAILS_ENV=production bundle exec rails assets:precompile
RAILS_ENV=production bundle exec rails db:migrate
```

Serve with Puma and a `DATABASE_URL` (and `RAILS_MASTER_KEY`) configured for your environment.

## Quick Start
bundle install && yarn install
rails db:create db:migrate db:seed
rails server          # terminal 1
bin/webpack --watch   # terminal 2

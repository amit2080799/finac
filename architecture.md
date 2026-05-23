# Finac Architecture

Finac is a personal finance application for tracking expenses. The UI is a **React single-page application (SPA)** served by Rails. Business logic, persistence, and authorization live on the **Rails API** backed by **PostgreSQL**.

## High-level overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Browser                                  │
│  React SPA (React Router) ── fetch + CSRF cookie ───────────────│
└───────────────────────────────┬─────────────────────────────────┘
                                │ HTTP (JSON + session cookie)
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Rails 7 (Puma)                                │
│  ┌──────────────┐   ┌─────────────────────────────────────────┐ │
│  │ HomeController│   │ Api::V1::* (JSON)                       │ │
│  │  → spa layout │   │  sessions, dashboard, expenses, users  │ │
│  └──────────────┘   └─────────────────────────────────────────┘ │
│         │                        │                               │
│         │              Devise (session) + CanCanCan (abilities)  │
│         ▼                        ▼                               │
│                    ActiveRecord models                           │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
                         PostgreSQL
```

| Layer | Technology | Responsibility |
|-------|------------|----------------|
| Frontend | React 19, React Router 6, Webpacker 5 | UI, routing, forms, client-side navigation |
| API | Rails controllers (`Api::V1`) | JSON endpoints, validation, authorization |
| Auth | Devise (cookie session) | Sign-in, sign-out, `current_user` |
| Authorization | CanCanCan (`Ability`) | Role-based access per resource |
| Data | ActiveRecord + PostgreSQL | Users, expenses, payments, lookup tables |
| Assets | Webpack (`app/javascript/packs/application.jsx`) | Bundle and serve the React app |

## Request flow

### SPA shell (any non-API page)

1. Browser requests `/`, `/login`, `/expenses/new`, etc.
2. `HomeController#index` renders `layouts/spa.html.haml` with an empty `<div id="root">`.
3. Webpack serves `application.js` (compiled from `application.jsx`), which mounts the React app.
4. React Router handles client-side routes; the server is not involved again until an API call or full page reload.

### API calls

1. React uses `app/javascript/finac/api/client.js` to `fetch` `/api/v1/...`.
2. Requests include:
   - `credentials: 'same-origin'` (Devise session cookie)
   - `X-CSRF-Token` from the `<meta name="csrf-token">` tag in the SPA layout
3. `Api::V1::BaseController` ensures the user is signed in (except session create).
4. CanCanCan checks abilities (`load_and_authorize_resource` or explicit rules).
5. Controllers return JSON; errors use HTTP status codes (`401`, `403`, `422`, etc.).

### Authentication flow

```
Login page → POST /api/v1/session { email, password }
           → Devise sign_in → session cookie set
           → GET /api/v1/session → { user: { id, email, role, role_label } }
Protected routes → AuthContext holds user; redirects to /login if missing
Logout → DELETE /api/v1/session → cookie cleared
```

Public self-registration is disabled (`devise_for :users, skip: [:registrations]`). Admins create accounts via the Users admin UI.

## Routing

### Rails (`config/routes.rb`)

| Route | Handler | Purpose |
|-------|---------|---------|
| `GET /api/v1/*` | `Api::V1::*` | JSON API |
| `GET /users/sign_in` | Devise | Legacy Devise sign-in (optional; app uses `/login`) |
| `GET /*` (catch-all) | `home#index` | SPA shell (excludes `/api`, `/packs`, `/rails`, `/users`) |
| `root` | `home#index` | Dashboard entry |

### React (`app/javascript/finac/App.jsx`)

| Path | Page | Access |
|------|------|--------|
| `/login` | Login | Public |
| `/` | Dashboard | Authenticated |
| `/expenses` | Dashboard (same list) | Authenticated |
| `/expenses/new` | Add expense | Authenticated |
| `/expenses/:id/edit` | Edit expense | Authenticated |
| `/admin/users` | User list | Admin / super_admin |
| `/admin/users/new` | Create user | Admin / super_admin |
| `/admin/users/:id/edit` | Edit user | Admin / super_admin |

Sidebar items for Analytics, Budgets, Reports, and Settings are placeholders (not implemented).

## API reference

Base path: `/api/v1` (JSON only).

### Session

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/session` | Current user or `401` |
| `POST` | `/session` | Sign in (`session[email]`, `session[password]`) |
| `DELETE` | `/session` | Sign out |

### Dashboard

| Method | Path | Query params | Response |
|--------|------|--------------|----------|
| `GET` | `/dashboard` | `month` (YYYY-MM), `page`, `per_page` | `summary`, `expenses[]`, `meta` (pagination) |

**Summary fields:** `total_expenses`, `transactions_count`, `latest_expense_date`, `top_category` (current month by default).

### Options (form metadata)

| Method | Path | Response |
|--------|------|----------|
| `GET` | `/options` | `expense_types`, `payment_modes`, `bank_details`, `assignable_roles` |

### Expenses

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/expenses/:id` | Single expense with nested payment |
| `POST` | `/expenses` | Create |
| `PATCH` | `/expenses/:id` | Update |
| `DELETE` | `/expenses/:id` | Delete |

**Create/update body:**

```json
{
  "expense": {
    "date": "2024-05-01",
    "description": "optional",
    "expense_type_id": 1,
    "payment_attributes": {
      "id": 1,
      "amount": "20000.00",
      "payment_mode_id": 1,
      "bank_detail_id": 1
    }
  }
}
```

`payment_attributes.id` is required on update so the nested payment record is updated in place.

### Users (admin)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/users` | Paginated list + `assignable_roles` |
| `GET` | `/users/:id` | User + `assignable_roles` |
| `POST` | `/users` | Create |
| `PATCH` | `/users/:id` | Update |
| `DELETE` | `/users/:id` | Delete (not self) |

## Data model

```
User
  └── role: enum (super_admin | admin | user)

Expense
  ├── belongs_to :expense_type
  ├── has_one :payment
  └── date, description

Payment
  ├── belongs_to :expense
  ├── belongs_to :payment_mode
  ├── belongs_to :bank_detail
  └── amount

ExpenseType, PaymentMode, BankDetail
  └── lookup tables (name, unique)
```

**Expense lifecycle:** An expense always has exactly one payment (amount, mode, bank). `Expense` accepts nested attributes for `payment`.

**Month scoping:** `Expense.in_month(month)` filters dashboard and summary metrics. `Expense.month_summary` aggregates totals for summary cards.

## Authorization (CanCanCan)

Defined in `app/models/ability.rb`:

| Role | Expenses | Users |
|------|----------|-------|
| **super_admin** | Full manage | Full manage |
| **admin** | Full manage | Manage except super_admin users; cannot modify own record via admin |
| **user** | Full manage | Read/update own profile only |

The React app hides the Users nav link unless `canManageUsers` is true (admin or super_admin). The API enforces the same rules server-side.

**Assignable roles:**

| Assigner | Can assign |
|----------|------------|
| super_admin | super_admin, admin, user |
| admin | admin, user |
| user | (none) |

## Frontend structure

```
app/javascript/
├── packs/
│   └── application.jsx          # Entry: mounts React into #root
└── finac/
    ├── App.jsx                  # Routes, auth guards, React.lazy code splitting
    ├── api/client.js            # HTTP client + endpoint helpers
    ├── context/AuthContext.jsx  # Session state, login/logout
    ├── components/
    │   ├── Layout.jsx           # Sidebar, header, footer
    │   ├── ExpenseForm.jsx
    │   ├── ExpensesTable.jsx
    │   ├── SummaryCard.jsx
    │   └── RolePicker.jsx
    ├── pages/
    │   ├── Dashboard.jsx
    │   ├── Login.jsx
    │   ├── AdminUsers.jsx
    │   └── AdminUserForm.jsx
    ├── utils/format.js          # Currency (INR), dates
    └── styles/finac.css         # Design system (Poppins, Figma colors)
```

Styling follows the Figma spec: primary `#2563EB`, success `#10B981`, warning `#F59E0B`, accent `#8B5CF6`, background `#F3F4F6`, font **Poppins** (loaded in the SPA layout).

### Code splitting

Route-level chunks are loaded on demand via `React.lazy` and `Suspense` in `App.jsx`:

| Webpack chunk | Loaded on route |
|---------------|-----------------|
| `dashboard` | `/` |
| `expenses` | `/expenses` |
| `expense-form` | `/expenses/new`, `/expenses/:id/edit` |
| `login` | `/login` |
| `admin-users` | `/admin/users` |
| `admin-user-form` | `/admin/users/new`, `/admin/users/:id/edit` |

`Layout`, `AuthContext`, and global CSS stay in the main bundle. While a chunk loads, `PageLoader` is shown.

## Key backend files

| File | Role |
|------|------|
| `app/controllers/home_controller.rb` | Serves SPA shell |
| `app/controllers/api/v1/base_controller.rb` | JSON auth, pagination helpers |
| `app/controllers/api/v1/sessions_controller.rb` | Login API |
| `app/controllers/api/v1/dashboards_controller.rb` | Dashboard aggregate + list |
| `app/controllers/api/v1/expenses_controller.rb` | Expense CRUD |
| `app/controllers/api/v1/users_controller.rb` | User admin CRUD |
| `app/controllers/concerns/expense_serializable.rb` | Shared JSON shapes |
| `app/models/expense.rb` | Scopes, `month_summary`, nested payment |
| `app/models/user.rb` | Roles, assignability helpers |
| `app/views/layouts/spa.html.haml` | Minimal HTML + CSRF + webpack pack |

## What was removed (legacy)

- Rails HAML views for expenses and admin users
- `ExpensesController` and `Admin::*` HTML controllers
- Turbolinks-driven multi-page expense flows
- PostgreSQL `roles` array on users (replaced by single `role` column)

## Testing

| Test | Location |
|------|----------|
| SPA shell | `test/controllers/home_controller_test.rb` |
| Dashboard API | `test/controllers/api/v1/dashboard_controller_test.rb` |
| User roles | `test/models/user_test.rb` |

Run: `bundle exec rails test`

## Deployment notes (summary)

1. Precompile assets: `RAILS_ENV=production bundle exec rails assets:precompile` (Webpacker compiles the React bundle).
2. Set `DATABASE_URL` and Rails master key for production.
3. Run migrations: `rails db:migrate`.
4. Serve with Puma; all non-API routes should fall through to the SPA (already configured in routes).

## Future extension points

- **Analytics / Budgets / Reports / Settings:** Sidebar links exist; add routes in `App.jsx` and matching API namespaces.
- **Expense delete in UI:** API supports `DELETE`; table action not yet wired in React.
- **Month picker on dashboard:** API accepts `month=YYYY-MM`; UI can add a filter control.
- **JWT / API tokens:** Not used today; session cookies only.

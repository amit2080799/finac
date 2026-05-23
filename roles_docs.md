# Finac — User Roles

Roles are implemented end to end: database column, Rails enum, CanCanCan authorization, JSON API, and a React admin UI.

## Roles overview

| Role | Label in UI | What they can do |
|------|-------------|------------------|
| **super_admin** | Super Admin | Everything (expenses + all users, including other super admins) |
| **admin** | Admin | Full expenses; manage users (admin/user only); **cannot** edit super admins or **their own** account via admin |
| **user** | User | Full expenses; **no** Users menu |

Each user has **one** role (`users.role` column), not multiple roles.

## Permissions (backend)

Enforced in `app/models/ability.rb` on every API request:

- **super_admin** → `can :manage, :all`
- **admin** → manage expenses + users, except super_admin users and self in admin
- **user** → manage expenses only

The React app hides the **Users** sidebar link for non-admins, but the API still enforces permissions if someone calls it directly.

## How to use

### 1. Get an admin account

**Option A — seed (empty database):**

```bash
rails db:seed
```

Login:

| Field | Value |
|-------|--------|
| Email | `admin@finac.local` |
| Password | `changeme123` |

This user is a **super_admin**.

**Option B — promote an existing user in console:**

```bash
rails console
```

```ruby
User.find_by(email: 'your@email.com')&.update!(role: :super_admin)
# or
User.find_by(email: 'your@email.com')&.update!(role: :admin)
```

### 2. Sign in

Open [http://localhost:3000/login](http://localhost:3000/login) and sign in with that account.

### 3. Manage users in the UI

If you are **admin** or **super_admin**:

1. Open **Users** in the sidebar (only visible for those roles).
2. Click **+ New user** — set email, password, and role (card picker).
3. **Edit** — change role or password.
4. **Delete** — remove another user (you cannot delete yourself).

**Routes:**

- `/admin/users` — list
- `/admin/users/new` — create
- `/admin/users/:id/edit` — edit

### 4. Who can assign which role

| You are | Can assign |
|---------|------------|
| **super_admin** | super_admin, admin, user |
| **admin** | admin, user only |
| **user** | (no user management) |

**Additional rules:**

- Admins **cannot** edit or delete **their own** account in the Users admin (avoids lockout / self-promotion).
- Admins **cannot** manage users who are **super_admin**.

### 5. See your current role

- Top-right profile dropdown shows your role label (e.g. “Super Admin”).
- Dashboard welcome message uses your role label.

## What roles do **not** change today

- **Expenses** (dashboard, list, add, edit) — all logged-in roles have the same expense access.
- **Analytics / Budgets / Reports / Settings** — sidebar links are placeholders (not implemented).
- **Public sign-up** — disabled (`devise_for :users, skip: [:registrations]`). New accounts are created by admins via the Users UI.

## Quick test checklist

1. Sign in as **super_admin**.
2. Create a **user** → sign out → sign in as that user → **Users** should not appear in the sidebar.
3. Create an **admin** → sign in as admin → **Users** appears; you cannot assign **super_admin**.

## Related code

| File | Purpose |
|------|---------|
| `app/models/user.rb` | Role enum, labels, assignability helpers |
| `app/models/ability.rb` | CanCanCan rules |
| `app/controllers/api/v1/users_controller.rb` | User CRUD API |
| `app/javascript/finac/pages/AdminUsers.jsx` | User list UI |
| `app/javascript/finac/pages/AdminUserForm.jsx` | Create/edit user + role picker |
| `app/javascript/finac/components/RolePicker.jsx` | Role selection UI |
| `app/javascript/finac/context/AuthContext.jsx` | `canManageUsers` flag |

For overall system design, see [architecture.md](./architecture.md).

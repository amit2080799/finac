import React, { useState } from 'react'
import { NavLink, Outlet, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

const NAV_ITEMS = [
  { to: '/', label: 'Dashboard', icon: '▦', end: true },
  { to: '/expenses', label: 'Expenses', icon: '₹' },
  { to: '/analytics', label: 'Analytics', icon: '↗', disabled: true },
  { to: '/budgets', label: 'Budgets', icon: '◫', disabled: true },
  { to: '/reports', label: 'Reports', icon: '☰', disabled: true },
  { to: '/settings', label: 'Settings', icon: '⚙', disabled: true }
]

export default function Layout() {
  const { user, logout, canManageUsers } = useAuth()
  const navigate = useNavigate()
  const [menuOpen, setMenuOpen] = useState(false)
  const [profileOpen, setProfileOpen] = useState(false)

  const handleLogout = async () => {
    await logout()
    navigate('/login')
  }

  return (
    <div className="finac-app">
      <aside className={`sidebar${menuOpen ? ' is-open' : ''}`}>
        <div className="sidebar__brand">
          <span className="sidebar__logo">💼</span>
          <span>Finac</span>
        </div>
        <nav className="sidebar__nav">
          {NAV_ITEMS.map((item) =>
            item.disabled ? (
              <span key={item.label} className="sidebar__link is-disabled" title="Coming soon">
                <span className="sidebar__icon">{item.icon}</span>
                {item.label}
              </span>
            ) : (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.end}
                className={({ isActive }) => `sidebar__link${isActive ? ' is-active' : ''}`}
                onClick={() => setMenuOpen(false)}
              >
                <span className="sidebar__icon">{item.icon}</span>
                {item.label}
              </NavLink>
            )
          )}
          {canManageUsers && (
            <NavLink
              to="/admin/users"
              className={({ isActive }) => `sidebar__link${isActive ? ' is-active' : ''}`}
              onClick={() => setMenuOpen(false)}
            >
              <span className="sidebar__icon">👥</span>
              Users
            </NavLink>
          )}
        </nav>
      </aside>

      <div className="finac-main">
        <header className="topbar">
          <button type="button" className="icon-btn" aria-label="Toggle menu" onClick={() => setMenuOpen((v) => !v)}>
            ☰
          </button>
          <div className="topbar__actions">
            <button type="button" className="icon-btn" aria-label="Notifications">🔔</button>
            <div className="profile-menu">
              <button type="button" className="profile-menu__trigger" onClick={() => setProfileOpen((v) => !v)}>
                <span className="avatar">{user?.email?.[0]?.toUpperCase()}</span>
                <span>{user?.role_label || 'User'}</span>
              </button>
              {profileOpen && (
                <div className="profile-menu__dropdown">
                  <div className="profile-menu__email">{user?.email}</div>
                  <button type="button" onClick={handleLogout}>Logout</button>
                </div>
              )}
            </div>
          </div>
        </header>

        <main className="page-content">
          <Outlet />
        </main>

        <footer className="app-footer">
          <span>© 2024 Finac. All rights reserved.</span>
          <div className="app-footer__links">
            <a href="#">Privacy Policy</a>
            <a href="#">Terms of Service</a>
          </div>
        </footer>
      </div>
    </div>
  )
}

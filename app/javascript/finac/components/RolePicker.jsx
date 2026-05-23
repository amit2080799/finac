import React, { useState } from 'react'

const ROLE_META = {
  super_admin: {
    label: 'Super Admin',
    description: 'Full access to all features and user management.',
    accent: '#dc3545'
  },
  admin: {
    label: 'Admin',
    description: 'Manage expenses and users, except super admins.',
    accent: '#fd7e14'
  },
  user: {
    label: 'User',
    description: 'Standard access to expenses and personal account.',
    accent: '#6c757d'
  }
}

export default function RolePicker({ selectedRole, roles, disabled, onChange }) {
  const [activeRole, setActiveRole] = useState(selectedRole || roles[0]?.value)

  if (!roles?.length) {
    return <p className="text-muted">No roles available to assign.</p>
  }

  const selectRole = (role) => {
    setActiveRole(role)
    onChange?.(role)
  }

  return (
    <div className="role-picker">
      <div className="role-picker__grid" role="radiogroup" aria-label="User role">
        {roles.map((role) => {
          const meta = ROLE_META[role.value] || { label: role.label, description: '', accent: '#2563EB' }
          const isSelected = activeRole === role.value

          return (
            <button
              key={role.value}
              type="button"
              role="radio"
              aria-checked={isSelected}
              disabled={disabled}
              className={`role-picker__card${isSelected ? ' is-selected' : ''}`}
              style={{ '--role-accent': meta.accent }}
              onClick={() => selectRole(role.value)}
            >
              <span className="role-picker__indicator" aria-hidden="true" />
              <span className="role-picker__title">{meta.label || role.label}</span>
              <span className="role-picker__description">{meta.description}</span>
            </button>
          )
        })}
      </div>
      <input type="hidden" name="role" value={activeRole} readOnly />
    </div>
  )
}

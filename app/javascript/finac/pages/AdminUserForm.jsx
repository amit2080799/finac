import React, { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { api } from '../api/client'
import RolePicker from '../components/RolePicker'

export default function AdminUserForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const isEdit = Boolean(id)

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [passwordConfirmation, setPasswordConfirmation] = useState('')
  const [role, setRole] = useState('user')
  const [roles, setRoles] = useState([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    const load = async () => {
      try {
        if (isEdit) {
          const data = await api.users.show(id)
          setEmail(data.user.email)
          setRole(data.user.role)
          setRoles(data.assignable_roles)
        } else {
          const data = await api.options.show()
          setRoles(data.assignable_roles)
          setRole(data.assignable_roles[0]?.value || 'user')
        }
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    load()
  }, [id, isEdit])

  const handleSubmit = async (event) => {
    event.preventDefault()
    setSaving(true)
    setError('')

    const payload = { email, role, password, password_confirmation: passwordConfirmation }

    try {
      if (isEdit) {
        await api.users.update(id, payload)
      } else {
        await api.users.create(payload)
      }
      navigate('/admin/users')
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  if (loading) return <div className="loading-state">Loading user...</div>

  return (
    <section className="panel">
      <div className="panel__header">
        <h1>{isEdit ? 'Edit user' : 'New user'}</h1>
        <p className="muted">{isEdit ? 'Update account details and role.' : 'Create a new account.'}</p>
      </div>

      {error && <div className="alert alert-danger">{error}</div>}

      <form className="expense-form" onSubmit={handleSubmit}>
        <label className="field field--full">
          <span>Email</span>
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        </label>

        <label className="field field--full">
          <span>Password</span>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required={!isEdit}
            autoComplete="new-password"
          />
          {isEdit && <small className="muted">Leave blank to keep the current password.</small>}
        </label>

        <label className="field field--full">
          <span>Confirm password</span>
          <input
            type="password"
            value={passwordConfirmation}
            onChange={(e) => setPasswordConfirmation(e.target.value)}
            required={!isEdit && password.length > 0}
            autoComplete="new-password"
          />
        </label>

        <div className="field field--full">
          <span>Role</span>
          <RolePicker
            selectedRole={role}
            roles={roles}
            disabled={roles.length <= 1}
            onChange={setRole}
          />
        </div>

        <div className="form-actions">
          <button type="button" className="btn btn-secondary" onClick={() => navigate('/admin/users')}>Cancel</button>
          <button type="submit" className="btn btn-primary" disabled={saving}>
            {saving ? 'Saving...' : isEdit ? 'Update user' : 'Create user'}
          </button>
        </div>
      </form>
    </section>
  )
}

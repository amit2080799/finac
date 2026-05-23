import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../api/client'

const roleClass = {
  super_admin: 'badge-danger',
  admin: 'badge-warning',
  user: 'badge-muted'
}

export default function AdminUsers() {
  const [data, setData] = useState({ users: [], meta: {} })
  const [page, setPage] = useState(1)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)

  const load = async () => {
    setLoading(true)
    setError('')
    try {
      const response = await api.users.index(page)
      setData(response)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    load()
  }, [page])

  const handleDelete = async (id, email) => {
    if (!window.confirm(`Delete ${email}?`)) return
    try {
      await api.users.destroy(id)
      load()
    } catch (err) {
      setError(err.message)
    }
  }

  if (loading) return <div className="loading-state">Loading users...</div>

  return (
    <section className="panel">
      <div className="panel__header panel__header--split">
        <div>
          <h1>Users</h1>
          <p className="muted">Manage accounts and access levels.</p>
        </div>
        <Link to="/admin/users/new" className="btn btn-primary">+ New user</Link>
      </div>

      {error && <div className="alert alert-danger">{error}</div>}

      <div className="table-wrap">
        <table className="data-table">
          <thead>
            <tr>
              <th>Email</th>
              <th>Role</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {data.users.map((user) => (
              <tr key={user.id}>
                <td>{user.email}</td>
                <td>
                  <span className={`badge ${roleClass[user.role] || 'badge-muted'}`}>{user.role_label}</span>
                </td>
                <td className="table-actions">
                  <Link to={`/admin/users/${user.id}/edit`} className="btn btn-secondary btn-sm">Edit</Link>
                  <button type="button" className="btn btn-danger btn-sm" onClick={() => handleDelete(user.id, user.email)}>
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {data.meta.total_pages > 1 && (
        <div className="pagination">
          <button type="button" className="btn btn-secondary btn-sm" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
            Previous
          </button>
          <span className="muted">Page {data.meta.current_page} of {data.meta.total_pages}</span>
          <button
            type="button"
            className="btn btn-secondary btn-sm"
            disabled={page >= data.meta.total_pages}
            onClick={() => setPage((p) => p + 1)}
          >
            Next
          </button>
        </div>
      )}
    </section>
  )
}

import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../api/client'
import ExpensesTable from '../components/ExpensesTable'
import { currentMonthParam } from '../utils/format'

export default function Expenses() {
  const [month, setMonth] = useState(currentMonthParam())
  const [data, setData] = useState({ expenses: [], meta: {} })
  const [page, setPage] = useState(1)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setPage(1)
  }, [month])

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      setError('')
      try {
        const response = await api.expenses.index({ month, page })
        setData(response)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    load()
  }, [month, page])

  const { expenses, meta } = data

  return (
    <div className="expenses-page">
      <section className="panel">
        <div className="panel__header panel__header--split">
          <div>
            <h1>Expenses</h1>
            <p className="muted">Track and manage your transactions.</p>
          </div>
          <Link to="/expenses/new" className="btn btn-primary">+ Add New Expense</Link>
        </div>

        <div className="expenses-toolbar">
          <label className="field field--inline">
            <span>Month</span>
            <input
              type="month"
              value={month}
              onChange={(e) => setMonth(e.target.value)}
            />
          </label>
        </div>

        {error && <div className="alert alert-danger">{error}</div>}
        {loading ? (
          <div className="loading-state">Loading expenses...</div>
        ) : (
          <>
            <ExpensesTable expenses={expenses} />

            {meta.total_pages > 1 && (
              <div className="pagination">
                <button
                  type="button"
                  className="btn btn-secondary btn-sm"
                  disabled={page <= 1}
                  onClick={() => setPage((p) => p - 1)}
                >
                  Previous
                </button>
                <span className="muted">Page {meta.current_page} of {meta.total_pages}</span>
                <button
                  type="button"
                  className="btn btn-secondary btn-sm"
                  disabled={page >= meta.total_pages}
                  onClick={() => setPage((p) => p + 1)}
                >
                  Next
                </button>
              </div>
            )}
          </>
        )}
      </section>
    </div>
  )
}

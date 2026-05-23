import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../api/client'
import { useAuth } from '../context/AuthContext'
import SummaryCard from '../components/SummaryCard'
import ExpensesTable from '../components/ExpensesTable'
import { currentMonthParam, formatCurrency, formatDate } from '../utils/format'

export default function Dashboard() {
  const { user } = useAuth()
  const [data, setData] = useState(null)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      setError('')
      try {
        const response = await api.dashboard.show({ month: currentMonthParam() })
        setData(response)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    load()
  }, [])

  if (loading) return <div className="loading-state">Loading dashboard...</div>
  if (error) return <div className="alert alert-danger">{error}</div>

  const { summary, recent_expenses: recentExpenses } = data

  return (
    <div className="dashboard">
      <section className="welcome-banner">
        <div>
          <h1>Welcome back, {user?.role_label || 'User'}!</h1>
          <p>Here’s an overview of your expenses.</p>
        </div>
        <div className="welcome-banner__art" aria-hidden="true">💼</div>
      </section>

      <section className="summary-grid">
        <SummaryCard
          label="Total Expenses"
          value={formatCurrency(summary.total_expenses)}
          caption="This Month"
          tone="blue"
        />
        <SummaryCard
          label="Transactions"
          value={summary.transactions_count}
          caption="This Month"
          tone="green"
        />
        <SummaryCard
          label="Latest Expense"
          value={formatDate(summary.latest_expense_date)}
          caption="Date"
          tone="orange"
        />
        <SummaryCard
          label="Top Category"
          value={summary.top_category || '—'}
          caption="This Month"
          tone="purple"
        />
      </section>

      <section className="panel">
        <div className="panel__header panel__header--split">
          <div>
            <h2>Recent Expenses</h2>
            <p className="muted">Latest activity this month.</p>
          </div>
          <Link to="/expenses" className="btn btn-secondary">View all expenses</Link>
        </div>

        <ExpensesTable expenses={recentExpenses} />

        {recentExpenses.length === 0 && (
          <p className="muted dashboard-empty-hint">
            No expenses yet.{' '}
            <Link to="/expenses/new">Add your first expense</Link>
          </p>
        )}
      </section>
    </div>
  )
}

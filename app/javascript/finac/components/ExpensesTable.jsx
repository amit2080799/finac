import React from 'react'
import { Link } from 'react-router-dom'
import { formatCurrency, formatDate } from '../utils/format'

export default function ExpensesTable({ expenses }) {
  if (!expenses.length) {
    return <div className="empty-state">No expenses recorded for this month yet.</div>
  }

  return (
    <div className="table-wrap">
      <table className="data-table">
        <thead>
          <tr>
            <th>Date</th>
            <th>Expense Type</th>
            <th>Payment Mode</th>
            <th>Bank Name</th>
            <th>Amount</th>
            <th>Description</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {expenses.map((expense) => (
            <tr key={expense.id}>
              <td>{formatDate(expense.date)}</td>
              <td className="capitalize">{expense.expense_type?.name}</td>
              <td>{expense.payment?.payment_mode?.name}</td>
              <td>{expense.payment?.bank_detail?.name}</td>
              <td>{formatCurrency(expense.payment?.amount)}</td>
              <td>{expense.description || '—'}</td>
              <td>
                <Link to={`/expenses/${expense.id}/edit`} className="btn btn-secondary btn-sm">
                  ✎ Edit
                </Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

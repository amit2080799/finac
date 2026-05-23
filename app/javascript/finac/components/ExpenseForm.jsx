import React, { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { api } from '../api/client'
import { toInputDate } from '../utils/format'

const emptyForm = {
  date: '',
  expense_type_id: '',
  payment_mode_id: '',
  bank_detail_id: '',
  amount: '',
  description: ''
}

export default function ExpenseForm({ title, subtitle, submitLabel }) {
  const { id: expenseId } = useParams()
  const navigate = useNavigate()
  const [options, setOptions] = useState({ expense_types: [], payment_modes: [], bank_details: [] })
  const [form, setForm] = useState(emptyForm)
  const [paymentId, setPaymentId] = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    const load = async () => {
      try {
        const optionsData = await api.options.show()
        setOptions(optionsData)

        if (expenseId) {
          const { expense } = await api.expenses.show(expenseId)
          setPaymentId(expense.payment?.id || null)
          setForm({
            date: toInputDate(expense.date),
            expense_type_id: String(expense.expense_type?.id || ''),
            payment_mode_id: String(expense.payment?.payment_mode?.id || ''),
            bank_detail_id: String(expense.payment?.bank_detail?.id || ''),
            amount: String(expense.payment?.amount || ''),
            description: expense.description || ''
          })
        }
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    load()
  }, [expenseId])

  const updateField = (field, value) => {
    setForm((current) => ({ ...current, [field]: value }))
  }

  const handleSubmit = async (event) => {
    event.preventDefault()
    setSaving(true)
    setError('')

    const paymentAttributes = {
      amount: form.amount,
      payment_mode_id: Number(form.payment_mode_id),
      bank_detail_id: Number(form.bank_detail_id)
    }
    if (paymentId) paymentAttributes.id = paymentId

    const payload = {
      date: form.date,
      description: form.description,
      expense_type_id: Number(form.expense_type_id),
      payment_attributes: paymentAttributes
    }

    try {
      if (expenseId) {
        await api.expenses.update(expenseId, payload)
      } else {
        await api.expenses.create(payload)
      }
      navigate('/')
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  if (loading) return <div className="loading-state">Loading form...</div>

  return (
    <section className="panel">
      <div className="panel__header panel__header--split">
        <div>
          <h1>{title}</h1>
          <p className="muted">{subtitle}</p>
        </div>
        <button type="button" className="icon-btn" aria-label="Go back" onClick={() => navigate(-1)}>
          ←
        </button>
      </div>

      {error && <div className="alert alert-danger">{error}</div>}

      <form className="expense-form" onSubmit={handleSubmit}>
        <div className="form-grid">
          <label className="field">
            <span>Date</span>
            <input
              type="date"
              value={form.date}
              onChange={(e) => updateField('date', e.target.value)}
              required
            />
          </label>

          <label className="field">
            <span>Expense Type</span>
            <select
              value={form.expense_type_id}
              onChange={(e) => updateField('expense_type_id', e.target.value)}
              required
            >
              <option value="">Select type</option>
              {options.expense_types.map((item) => (
                <option key={item.id} value={item.id}>{item.name}</option>
              ))}
            </select>
          </label>

          <label className="field">
            <span>Payment Mode</span>
            <select
              value={form.payment_mode_id}
              onChange={(e) => updateField('payment_mode_id', e.target.value)}
              required
            >
              <option value="">Select mode</option>
              {options.payment_modes.map((item) => (
                <option key={item.id} value={item.id}>{item.name}</option>
              ))}
            </select>
          </label>

          <label className="field">
            <span>Bank Name</span>
            <select
              value={form.bank_detail_id}
              onChange={(e) => updateField('bank_detail_id', e.target.value)}
              required
            >
              <option value="">Select bank</option>
              {options.bank_details.map((item) => (
                <option key={item.id} value={item.id}>{item.name}</option>
              ))}
            </select>
          </label>

          <label className="field">
            <span>Amount</span>
            <div className="input-prefix">
              <span>₹</span>
              <input
                type="number"
                min="0"
                step="0.01"
                value={form.amount}
                onChange={(e) => updateField('amount', e.target.value)}
                required
              />
            </div>
          </label>
        </div>

        <label className="field field--full">
          <span>Description (Optional)</span>
          <textarea
            rows={5}
            maxLength={500}
            value={form.description}
            onChange={(e) => updateField('description', e.target.value)}
            placeholder="Add notes about this expense"
          />
          <small className="muted">{form.description.length}/500</small>
        </label>

        <div className="form-actions">
          <button type="submit" className="btn btn-primary" disabled={saving}>
            {saving ? 'Saving...' : submitLabel}
          </button>
        </div>
      </form>
    </section>
  )
}

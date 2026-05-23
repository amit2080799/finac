import React from 'react'

export default function SummaryCard({ label, value, caption, tone = 'blue' }) {
  return (
    <article className={`summary-card summary-card--${tone}`}>
      <p className="summary-card__label">{label}</p>
      <h3 className="summary-card__value">{value}</h3>
      <p className="summary-card__caption">{caption}</p>
    </article>
  )
}

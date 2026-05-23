import React from 'react'

export default function PageLoader({ message = 'Loading page...' }) {
  return <div className="loading-state app-loading">{message}</div>
}

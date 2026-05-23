const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.content

const defaultHeaders = () => ({
  Accept: 'application/json',
  'Content-Type': 'application/json',
  'X-CSRF-Token': csrfToken()
})

async function parseResponse(response) {
  if (response.status === 204) return null

  const data = await response.json().catch(() => ({}))
  if (!response.ok) {
    const message = data.error || data.errors?.join(', ') || 'Request failed'
    throw new Error(message)
  }
  return data
}

export async function apiRequest(path, options = {}) {
  const response = await fetch(path, {
    credentials: 'same-origin',
    headers: { ...defaultHeaders(), ...options.headers },
    ...options
  })

  return parseResponse(response)
}

export const api = {
  session: {
    show: () => apiRequest('/api/v1/session'),
    create: (session) => apiRequest('/api/v1/session', { method: 'POST', body: JSON.stringify({ session }) }),
    destroy: () => apiRequest('/api/v1/session', { method: 'DELETE' })
  },
  dashboard: {
    show: (params = {}) => {
      const query = new URLSearchParams(params).toString()
      return apiRequest(`/api/v1/dashboard${query ? `?${query}` : ''}`)
    }
  },
  options: {
    show: () => apiRequest('/api/v1/options')
  },
  expenses: {
    index: (params = {}) => {
      const query = new URLSearchParams(params).toString()
      return apiRequest(`/api/v1/expenses${query ? `?${query}` : ''}`)
    },
    show: (id) => apiRequest(`/api/v1/expenses/${id}`),
    create: (expense) => apiRequest('/api/v1/expenses', { method: 'POST', body: JSON.stringify({ expense }) }),
    update: (id, expense) => apiRequest(`/api/v1/expenses/${id}`, { method: 'PATCH', body: JSON.stringify({ expense }) }),
    destroy: (id) => apiRequest(`/api/v1/expenses/${id}`, { method: 'DELETE' })
  },
  users: {
    index: (page = 1) => apiRequest(`/api/v1/users?page=${page}`),
    show: (id) => apiRequest(`/api/v1/users/${id}`),
    create: (user) => apiRequest('/api/v1/users', { method: 'POST', body: JSON.stringify({ user }) }),
    update: (id, user) => apiRequest(`/api/v1/users/${id}`, { method: 'PATCH', body: JSON.stringify({ user }) }),
    destroy: (id) => apiRequest(`/api/v1/users/${id}`, { method: 'DELETE' })
  }
}

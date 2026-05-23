import React, { Suspense, lazy } from 'react'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import Layout from './components/Layout'
import PageLoader from './components/PageLoader'
import './styles/finac.css'

const Dashboard = lazy(() => import(/* webpackChunkName: "dashboard" */ './pages/Dashboard'))
const Expenses = lazy(() => import(/* webpackChunkName: "expenses" */ './pages/Expenses'))
const Login = lazy(() => import(/* webpackChunkName: "login" */ './pages/Login'))
const AdminUsers = lazy(() => import(/* webpackChunkName: "admin-users" */ './pages/AdminUsers'))
const AdminUserForm = lazy(() => import(/* webpackChunkName: "admin-user-form" */ './pages/AdminUserForm'))
const ExpenseForm = lazy(() => import(/* webpackChunkName: "expense-form" */ './components/ExpenseForm'))

function ProtectedRoute({ children }) {
  const { user, loading } = useAuth()

  if (loading) return <PageLoader message="Loading Finac..." />
  if (!user) return <Navigate to="/login" replace />
  return children
}

function AdminRoute({ children }) {
  const { canManageUsers } = useAuth()
  if (!canManageUsers) return <Navigate to="/" replace />
  return children
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Suspense fallback={<PageLoader />}>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route
              element={
                <ProtectedRoute>
                  <Layout />
                </ProtectedRoute>
              }
            >
              <Route index element={<Dashboard />} />
              <Route path="/expenses" element={<Expenses />} />
              <Route
                path="/expenses/new"
                element={
                  <ExpenseForm
                    title="Add New Expense"
                    subtitle="Fill in the details to add a new expense."
                    submitLabel="Save Expense"
                  />
                }
              />
              <Route
                path="/expenses/:id/edit"
                element={
                  <ExpenseForm
                    title="Edit Expense"
                    subtitle="Update the expense details."
                    submitLabel="Update Expense"
                  />
                }
              />
              <Route
                path="/admin/users"
                element={
                  <AdminRoute>
                    <AdminUsers />
                  </AdminRoute>
                }
              />
              <Route
                path="/admin/users/new"
                element={
                  <AdminRoute>
                    <AdminUserForm />
                  </AdminRoute>
                }
              />
              <Route
                path="/admin/users/:id/edit"
                element={
                  <AdminRoute>
                    <AdminUserForm />
                  </AdminRoute>
                }
              />
            </Route>
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Suspense>
      </BrowserRouter>
    </AuthProvider>
  )
}

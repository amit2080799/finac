# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


ExpenseType.create([
  {
    expense_type: 'electricity'
  },
  {
    expense_type: 'loan'
  },
  {
    expense_type: 'medical'
  },{
    expense_type: 'self'
  },
  {
    expense_type: 'fuel'
  },
  {
    expense_type: 'miscellaneous'
  }
  ])

PaymentMode.create([
  {
    name: 'PhonePe'
  },
  {
    name: 'Cash'
  },
  {
    name: 'Google Pay'
  },
  {
    name: 'Amazon Pay'
  },
  {
    name: 'Whatsapp UPI'
  }
])

BankDetail.create([
  {
    name: 'HDFC'
  },
  {
    name: 'Federal'
  },
  {
    name: 'SBI'
  }
])

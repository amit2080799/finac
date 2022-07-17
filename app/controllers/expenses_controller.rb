# frozen_string_literal: true

# ExpensesController class
class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[ show edit update destroy ]

  # GET /expenses or /expenses.json
  def index
    @expenses = Expense.construct_expense_data
  end

  # GET /expenses/1 or /expenses/1.json
  def show
  end

  # GET /expenses/new
  def new
    expense_data = Expense.fetch_expense_data
    @expense_types = expense_data[0]
    @payment_modes = expense_data[1]
    @bank_details = expense_data[2]
    @expense = Expense.new
  end

  # GET /expenses/1/edit
  def edit
    @expense = Expense.find_by(id: params['id'].to_i)
    expense_data = Expense.fetch_expense_data
    @expense_types = expense_data[0]
    @payment_modes = expense_data[1]
    @bank_details = expense_data[2]
  end

  # POST /expenses or /expenses.json
  def create
    @expense = Expense.create(construct_expense_params_data)

    respond_to do |format|
      if @expense.save
        format.html { redirect_to expense_url(@expense), notice: 'Expense was successfully created.' }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenses/1 or /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to expense_url(@expense), notice: 'Expense was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1 or /expenses/1.json
  def destroy
    @expense.destroy

    respond_to do |format|
      format.html { redirect_to expenses_url, notice: "Expense was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense
    @expense = Expense.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def expense_params
    params.fetch(:expense, {})
  end

  def construct_expense_params_data
    {
      date: params['date'],
      expense_type: params['expense_type'],
      payment_mode_name: params['payment_mode'],
      bank_name: params['bank_name'],
      description: params['description'],
      amount: params['amount']
    }.with_indifferent_access
  end
end

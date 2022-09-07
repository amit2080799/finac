# frozen_string_literal: true

# ExpensesController class
class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy]

  # GET /expenses or /expenses.json
  def index
    all_expenses = Expense.fetch_expenses
    @expenses = Kaminari.paginate_array(all_expenses).page(params[:page])
  end

  # GET /expenses/1 or /expenses/1.json
  def show
    @expense = Expense.find params[:id]
    render @expense
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
    expense_data = @expense.fetch_expense_data
    @expense_types = expense_data[0]
    @payment_modes = expense_data[1]
    @bank_details = expense_data[2]
  end

  # GET /expenses/1/edit
  def edit
    @expense = Expense.find_by(id: params['id'].to_i)
    expense_data = @expense.fetch_expense_data
    @expense_types = expense_data[0]
    @payment_modes = expense_data[1]
    @bank_details = expense_data[2]
  end

  # POST /expenses or /expenses.json
  def create
    @expense = Expense.new.create_expense(expense_params)

    respond_to do |format|
      if @expense.save!
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
    expense = @expense.update_expense(expense_params)

    respond_to do |format|
      if expense
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
      format.html { redirect_to expenses_url, notice: 'Expense was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def sort
    @sorted_expenses = Expense.sort_expenses(params[:name])
    render json: @sorted_expenses
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense
    @expense = Expense.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def expense_params
    params.fetch(:expense, {}).permit(
      :date,
      :description,
      :expense_type_id,
      :expense_type,
      :payment_mode,
      :bank_name,
      :amount,
      payment_attributes: %i[id amount payment_mode_id bank_detail_id]
    )
  end
end

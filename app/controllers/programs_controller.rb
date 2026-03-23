class ProgramsController < ApplicationController
  before_action :set_program, only: %i[show edit update destroy]

  def index
    @programs = policy_scope(Program).includes(:shifts).ordered
  end

  def show
    @shifts = @program.shifts.upcoming.ordered.includes(:shift_assignments)
    @pagy, @shifts = pagy(@shifts, items: 20)
  end

  def new
    authorize Program
    @program = Program.new
  end

  def create
    authorize Program
    @program = Program.new(program_params)
    @program.organisation = current_user.organisation

    if @program.save
      redirect_to @program, notice: "Program created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @program
  end

  def update
    authorize @program

    if @program.update(program_params)
      redirect_to @program, notice: "Program updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @program
    @program.destroy
    redirect_to programs_path, notice: "Program deleted."
  end

  private

  def set_program
    @program = policy_scope(Program).find(params[:id])
  end

  def program_params
    params.require(:program).permit(:name, :description)
  end

  include Pagy::Method
end

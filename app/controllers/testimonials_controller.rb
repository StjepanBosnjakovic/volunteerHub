class TestimonialsController < ApplicationController
  include Pagy::Method

  before_action :set_testimonial, only: %i[show edit update destroy publish unpublish]

  def index
    authorize Testimonial
    scope = policy_scope(Testimonial)
    scope = current_user.admin? ? scope.ordered : scope.published.ordered
    @pagy, @testimonials = pagy(scope, items: 20)
  end

  def show
    authorize @testimonial
  end

  def new
    authorize Testimonial
    @testimonial = Testimonial.new
  end

  def create
    authorize Testimonial
    @testimonial = Testimonial.new(testimonial_params)
    @testimonial.organisation = current_user.organisation

    if @testimonial.save
      redirect_to testimonials_path, notice: "Testimonial saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @testimonial
  end

  def update
    authorize @testimonial

    if @testimonial.update(testimonial_params)
      redirect_to testimonial_path(@testimonial), notice: "Testimonial updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @testimonial
    @testimonial.destroy
    redirect_to testimonials_path, notice: "Testimonial deleted."
  end

  def publish
    authorize @testimonial, :publish?
    @testimonial.publish!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "testimonial_#{@testimonial.id}",
          partial: "testimonials/testimonial_row",
          locals:  { testimonial: @testimonial }
        )
      end
      format.html { redirect_to testimonials_path, notice: "Testimonial published." }
    end
  end

  def unpublish
    authorize @testimonial, :publish?
    @testimonial.unpublish!
    redirect_to testimonials_path, notice: "Testimonial unpublished."
  end

  private

  def set_testimonial
    @testimonial = policy_scope(Testimonial).find(params[:id])
  end

  def testimonial_params
    params.require(:testimonial).permit(:volunteer_profile_id, :quote, :consent_given, :published)
  end
end

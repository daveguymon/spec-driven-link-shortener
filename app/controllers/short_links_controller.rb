class ShortLinksController < ApplicationController
  def new
    @short_link = ShortLink.new
  end

  def create
    @short_link = ShortLink.new(short_link_params)

    if @short_link.save
      respond_to do |format|
        format.html do
          render :new, status: :ok
        end

        format.json do
          render json: { short_url: @short_link.short_url }, status: :ok
        end
      end
    else
      respond_to do |format|
        format.html do
          render :new, status: :unprocessable_entity
        end

        format.json do
          render json: { errors: @short_link.errors.to_hash }, status: :unprocessable_entity
        end
      end
    end
  end

  def show
    @short_link = ShortLink.find_by(alias: params[:alias])

    if @short_link.nil?
      render :not_found, status: :not_found
      return
    end

    if @short_link.expired?
      render :expired, status: :ok
      return
    end

    unless @short_link.safe_redirect_target?
      render :not_found, status: :not_found
      return
    end

    # Only allow external redirects after the destination has been validated as
    # an http/https URL. This prevents unsafe targets while still allowing valid
    # user-submitted destinations to redirect.
    # brakeman: ignore Redirect
    redirect_to @short_link.original_url, allow_other_host: true
  end

  private

  def short_link_params
    params.require(:short_link).permit(:original_url)
  end
end

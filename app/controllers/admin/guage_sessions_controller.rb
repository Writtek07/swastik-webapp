# Opening and adjusting gauge sessions: owners and super users only. The
# sessions are listed on the gauge price sheet, so every action returns there.
class Admin::GuageSessionsController < Admin::BaseController
  require_role :owner

  before_action :set_session, only: %i[edit update]

  def new
    # Suggest the year after the latest session, or a year from today.
    latest = GuageSession.chronological.first
    starts_on = latest && latest.ends_on >= Date.current ? latest.ends_on + 1 : Date.current
    @guage_session = GuageSession.new(starts_on: starts_on, ends_on: starts_on + 1.year - 1)
  end

  def create
    @guage_session = GuageSession.new(session_params.merge(created_by: current_admin))

    if @guage_session.save
      redirect_to admin_guage_prices_path(session_id: @guage_session.id), notice: "Opened the #{@guage_session.label} gauge session (#{@guage_session.date_range})."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @guage_session.update(session_params)
      redirect_to admin_guage_prices_path(session_id: @guage_session.id), notice: "Updated the #{@guage_session.label} gauge session (#{@guage_session.date_range})."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_session
    @guage_session = GuageSession.find(params[:id])
  end

  def session_params
    params.expect(guage_session: %i[starts_on ends_on])
  end
end

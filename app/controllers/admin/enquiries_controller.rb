# Enquiries sent from the public contact form. Read-only, and open to every role.
class Admin::EnquiriesController < Admin::BaseController
  def index
    @query = params[:q].to_s.strip

    enquiries = Enquiry.recent
    if @query.present?
      term = "%#{Enquiry.sanitize_sql_like(@query)}%"
      enquiries = enquiries.where("name ILIKE :term OR company ILIKE :term OR email ILIKE :term OR phone ILIKE :term", term: term)
    end
    @pagy, @enquiries = pagy(enquiries)
  end

  def show
    @enquiry = Enquiry.find(params[:id])
  end
end

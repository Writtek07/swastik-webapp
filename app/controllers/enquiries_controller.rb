class EnquiriesController < ApplicationController
  def create
    @enquiry = Enquiry.new(enquiry_params)

    if @enquiry.save
      track_event "generate_lead", form_name: "enquiry", product_category: @enquiry.product_name
      redirect_to contact_path(anchor: "enquiry"), notice: "Thanks — your enquiry is with our sales desk. We usually respond within one working day."
    else
      # Field names only; the submitted values may be personal data.
      track_event "enquiry_error", form_name: "enquiry", error_fields: @enquiry.errors.attribute_names.join(",")
      redirect_to contact_path(anchor: "enquiry"), alert: @enquiry.errors.full_messages.to_sentence
    end
  end

  private

  def enquiry_params
    params.require(:enquiry).permit(
      :name, :company, :email, :phone, :product_key, :quantity, :delivery_location, :message
    )
  end
end

class TicketsController < ApplicationController
  before_action :authenticate

  def new
    raise ActionController::RoutingError, t('message.exception.invalid_tickets_new')
  end

  def create
    ticket = current_user.tickets.build do |t|
      t.event_id = params[:event_id]
      t.comment = params[:ticket][:comment]
    end
    if ticket.save
      flash[:notice] = t 'message.notice.joined_event'
      head 201
    else
      render json: { messages: ticket.errors.full_messages }, status: 422
    end
  end

  def destroy
    ticket = current_user.tickets.find_by!(event_id: params[:event_id])
    ticket.destroy!
    redirect_to event_path(params[:event_id]), notice: t('message.notice.canceled_event')
  end
end

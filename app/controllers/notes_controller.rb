class NotesController < ApplicationController
  def create
    @note = Note.new(note_params)
    if @note.save
      redirect_to @note.shipment, notice: 'Observação adicionada'
    else
      redirect_to @note.shipment, notice: @note.errors.full_messages
    end
  end

  private

  def note_params
    params.require(:note).permit(:shipment_id, :description).merge(user: current_user)
  end
end

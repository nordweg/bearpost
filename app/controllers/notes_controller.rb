class NotesController < ApplicationController
  def create
    @note = Note.new(note_params)
    respond_to do |format|
      if @note.save
        format.html { redirect_to @note.shipment, notice: 'Anotação adicionada' }
        format.json { render :show, status: :created, location: @note }
      else
        format.html { render :new }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def note_params
    params.require(:note).permit(:shipment_id, :description).merge(user: current_user)
  end
end

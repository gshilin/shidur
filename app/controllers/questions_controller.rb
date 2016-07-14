class QuestionsController < ApplicationController
  layout 'question'

  def index
    @questions = Message.where(type: 'question').order(:id).all
  end

  def new
    @question = Question.new
  end
end

class QuestionsController < ApplicationController
  layout 'question'

  def index
    @questions = Message.where(type: 'question', language: :he).order(:id).all
  end

  def new
    @question = Question.new
  end
end

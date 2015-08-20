class QuestionsController < ApplicationController
  layout 'question'

  def index
    @questions = Message.where(type: 'question').all
  end

  def new
    @question = Question.new
  end
end

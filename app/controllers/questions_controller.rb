class QuestionsController < ApplicationController
  layout 'question'

  def index
  end

  def new
    @question = Question.new
  end
end

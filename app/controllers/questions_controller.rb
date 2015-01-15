class QuestionsController < ApplicationController
  layout 'question'

  def show
    question = Question.first
    render text: question.try(:question), layout: false
  end

  def new
    @question = Question.new
  end

  def create
    question = Question.first
    if question
      question.update_attribute(:question, params[:question])
    else
      Question.create(question: params[:question])
    end
    render text: 'OK', layout: false
  end
end

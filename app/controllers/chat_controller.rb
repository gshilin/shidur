class ChatController < WebsocketRails::BaseController

  def initialize_session
    # puts '### Session Initialized ###'
  end

  def client_connected
    system_msg :new_message, 'מחובר'
  end

  def new_message
    user_msg :new_message, message[:user_name], message[:msg_body].dup
  end

  def client_disconnected
    system_msg :disconnect, "#{client_id} מנותק"
  end

  def new_question
    question = Question.first
    if question
      question.update_attribute(:question, message[:msg_body].dup)
    else
      Question.create(question: message[:msg_body].dup)
    end
    user_msg :got_new_question, '<span style="color: red; background: yellow; padding: 0 2px;">שאלה</span>'.html_safe, message[:msg_body].dup
    system_msg :new_message, 'השעלה התקבלה'
  end

  private

  def system_msg(ev, msg)
    broadcast_message ev, {
                            user_name: 'מערכת',
                            received:  Time.now.to_s(:short),
                            msg_body:  msg
                        }
  end

  def user_msg(ev, user_name, msg)
    broadcast_message ev, {
                            user_name: user_name,
                            received:  Time.now.to_s(:short),
                            msg_body:  ERB::Util.html_escape(msg)
                        }
  end

end

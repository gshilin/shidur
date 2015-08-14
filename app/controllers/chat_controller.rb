class ChatController < FayeRails::Controller

  channel '/faye' do
    monitor :subscribe do
      system_msg :new_message, "#{client_id} מחובר"
    end
    monitor :unsubscribe do
      system_msg :new_message, "#{client_id} מנותק"
    end
    monitor :publish do
      system_msg :new_message, "#{client_id} published #{data.inspect} to #{channel}"
    end

    subscribe do
      puts "Received on #{channel} from #{client_id}: #{data.inspect}"
    end
  end

  def new_message
    user_msg :new_message, message[:user_name], message[:msg_body].dup
  end

  def new_question
    question = Question.first
    if question
      question.update_attribute(:question, message[:msg_body].dup)
    else
      Question.create(question: message[:msg_body].dup)
    end
    user_msg :got_new_question, '<span style="color: red; background: yellow; padding: 0 2px;">שאלה</span>'.html_safe, message[:msg_body].dup
    system_msg :new_message, 'שאלה לסדנה​ התקבלה'
  end

  private

  def system_msg(ev, msg)
    publish ev, {
                  user_name: 'מערכת',
                  received:  Time.now.to_s(:short),
                  msg_body:  msg
              }
  end

  def user_msg(ev, user_name, msg)
    publish ev, {
                  user_name: user_name,
                  received:  Time.now.to_s(:short),
                  msg_body:  ERB::Util.html_escape(msg)
              }
  end

end

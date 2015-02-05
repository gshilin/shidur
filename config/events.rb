WebsocketRails::EventMap.describe do

  subscribe :client_connected, 'chat#client_connected'
  subscribe :new_message, 'chat#new_message'
  subscribe :new_user, 'chat#new_user'
  subscribe :new_question, 'chat#new_question' # question to Display
  subscribe :client_disconnected, 'chat#client_disconnected'

end

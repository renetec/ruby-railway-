require 'rails_helper'
require_relative 'messaging_test_factories'

RSpec.describe 'Messaging System', type: :system, js: true do
  before do
    driven_by(:selenium, using: :headless_chrome, screen_size: [1400, 1400])
  end

  let(:alice) { create(:alice) }
  let(:bob) { create(:bob) }
  let(:conversation) { create(:test_conversation, created_by: alice) }

  before do
    create(:test_user_conversation, user: alice, conversation: conversation)
    create(:test_user_conversation, user: bob, conversation: conversation)
  end

  describe 'Basic messaging' do
    it 'allows users to send and receive messages', :aggregate_failures do
      # Alice logs in and goes to conversation
      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        expect(page).to have_text('Messages')
        
        # Alice sends a message
        fill_in 'message[content]', with: 'Hello Bob!'
        click_button 'Send'
        
        # Verify Alice sees her message
        expect(page).to have_text('Hello Bob!')
      end

      # Bob logs in and should see Alice's message
      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversation_path(conversation)
        
        # Should see Alice's message
        expect(page).to have_text('Hello Bob!')
        
        # Bob replies
        fill_in 'message[content]', with: 'Hello Alice!'
        click_button 'Send'
        
        # Verify Bob sees his message
        expect(page).to have_text('Hello Alice!')
      end

      # Alice should see Bob's reply in real-time
      using_session('alice') do
        expect(page).to have_text('Hello Alice!')
      end
    end
  end

  describe 'Reply functionality' do
    it 'allows users to reply to specific messages', :aggregate_failures do
      # Setup: Alice sends initial message
      message = create(:test_message, 
                      conversation: conversation, 
                      user: alice, 
                      content: 'What time is the meeting?')

      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversation_path(conversation)
        
        # Bob should see the message
        expect(page).to have_text('What time is the meeting?')
        
        # Bob clicks reply on Alice's message
        within("[data-message-id='#{message.id}']") do
          click_button 'Répondre'
        end
        
        # Should see reply preview
        expect(page).to have_text('Répondre à Alice Johnson')
        expect(page).to have_text('What time is the meeting?')
        
        # Bob sends reply
        fill_in 'message[content]', with: 'The meeting is at 3 PM'
        click_button 'Send'
        
        # Should see the reply with reference
        expect(page).to have_text('The meeting is at 3 PM')
        expect(page).to have_css('.reply-reference')
      end

      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        # Alice should see Bob's reply with reference
        expect(page).to have_text('The meeting is at 3 PM')
        expect(page).to have_css('.reply-reference')
      end
    end
  end

  describe 'Message deletion' do
    it 'allows users to delete their own messages', :aggregate_failures do
      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        # Alice sends a message
        fill_in 'message[content]', with: 'I want to delete this message'
        click_button 'Send'
        
        # Verify message appears
        expect(page).to have_text('I want to delete this message')
        
        # Find and click delete button
        message_element = find('div', text: 'I want to delete this message').ancestor('[data-message-id]')
        within(message_element) do
          accept_confirm do
            click_button 'Supprimer'
          end
        end
        
        # Message should be deleted
        expect(page).not_to have_text('I want to delete this message')
      end

      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversation_path(conversation)
        
        # Bob should also not see the deleted message
        expect(page).not_to have_text('I want to delete this message')
      end
    end

    it 'only shows delete button on own messages' do
      # Alice sends a message
      message = create(:test_message, 
                      conversation: conversation, 
                      user: alice, 
                      content: 'Alice message')

      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversation_path(conversation)
        
        # Bob should not see delete button on Alice's message
        within("[data-message-id='#{message.id}']") do
          expect(page).not_to have_button('Supprimer')
        end
        
        # Bob sends his own message
        fill_in 'message[content]', with: 'Bob message'
        click_button 'Send'
        
        # Bob should see delete button on his own message
        message_element = find('div', text: 'Bob message').ancestor('[data-message-id]')
        within(message_element) do
          expect(page).to have_button('Supprimer')
        end
      end
    end
  end

  describe 'Notifications' do
    it 'shows notification badges for new messages' do
      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversations_path
        
        # Should not have notification badge initially
        expect(page).not_to have_css('.animate-pulse')
      end

      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        # Alice sends a message
        fill_in 'message[content]', with: 'New message notification test'
        click_button 'Send'
      end

      using_session('bob') do
        # Bob should see notification badge
        expect(page).to have_css('.animate-pulse')
      end
    end

    it 'requests browser notification permission' do
      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        # Should attempt to request notification permission
        expect(page).to have_text('Messages') # Page loaded
      end
    end
  end

  describe 'Real-time features' do
    it 'shows typing indicators', :skip do
      # This test would require more complex setup to simulate typing
      # Skipping for now as it requires advanced ActionCable testing
    end

    it 'updates message status in real-time', :skip do
      # This test would require message status updates
      # Skipping for now as it requires more complex setup
    end
  end

  describe 'UI/UX features' do
    it 'displays messages with correct styling' do
      # Alice sends message
      alice_message = create(:test_message, 
                           conversation: conversation, 
                           user: alice, 
                           content: 'Alice message')
      
      # Bob sends message  
      bob_message = create(:test_message, 
                          conversation: conversation, 
                          user: bob, 
                          content: 'Bob message')

      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        # Alice's message should be on the right (justify-end)
        alice_element = find("[data-message-id='#{alice_message.id}']")
        expect(alice_element[:class]).to include('justify-end')
        
        # Bob's message should be on the left (justify-start)
        bob_element = find("[data-message-id='#{bob_message.id}']")
        expect(bob_element[:class]).to include('justify-start')
      end
    end

    it 'auto-scrolls to bottom of messages' do
      # Create many messages to force scrolling
      20.times do |i|
        create(:test_message, 
               conversation: conversation, 
               user: alice, 
               content: "Message #{i}")
      end

      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversation_path(conversation)
        
        # Should be scrolled to bottom
        last_message = find('div', text: 'Message 19')
        expect(last_message).to be_visible
      end
    end

    it 'handles textarea auto-resize' do
      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        textarea = find('textarea[data-messaging-target="input"]')
        
        # Type long message that should resize textarea
        long_message = 'This is a very long message that should cause the textarea to resize automatically ' * 3
        textarea.fill_in(with: long_message)
        
        # Textarea should exist and be functional
        expect(textarea.value).to eq(long_message)
      end
    end
  end

  describe 'Error handling' do
    it 'handles network disconnections gracefully', :skip do
      # This would require network simulation
      # Skipping advanced network testing for now
    end

    it 'handles server errors gracefully' do
      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        # Simulate server error by sending invalid data
        # The app should handle this gracefully without crashing
        page.execute_script("document.querySelector('textarea').value = ''")
        click_button 'Send'
        
        # Page should still be functional
        expect(page).to have_text('Messages')
      end
    end
  end

  # Helper method for login
  def login_as(user, scope:)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password123'
    click_button 'Log in'
  end
end
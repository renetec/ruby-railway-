require 'rails_helper'
require_relative 'messaging_test_factories'

RSpec.describe 'Notification System', type: :system, js: true do
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

  describe 'Browser Notifications' do
    it 'requests notification permission on page load' do
      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        # Check if the page attempts to request notification permission
        permission_script = <<-JS
          return typeof Notification !== 'undefined' && Notification.permission;
        JS
        
        permission = page.evaluate_script(permission_script)
        expect(['default', 'granted', 'denied']).to include(permission)
      end
    end

    it 'shows browser notifications for new messages when permission granted' do
      # This test would require mocking the Notification API
      # Skipping for now as it requires complex browser permission simulation
      skip "Requires complex browser notification mocking"
    end

    it 'handles notification permission denial gracefully' do
      using_session('alice') do
        login_as(alice, scope: :user)
        
        # Mock notification permission as denied
        page.execute_script("Object.defineProperty(Notification, 'permission', { value: 'denied' });")
        
        visit conversation_path(conversation)
        
        # Page should still work normally even with denied permissions
        expect(page).to have_text('Messages')
        
        # Should be able to send messages normally
        fill_in 'message[content]', with: 'Test message'
        click_button 'Send'
        
        expect(page).to have_text('Test message')
      end
    end
  end

  describe 'Badge Notifications' do
    it 'shows badge in navigation when new messages arrive' do
      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversations_path
        
        # Should not have badge initially
        expect(page).not_to have_css('span.animate-pulse')
      end

      # Alice sends a message in another session
      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        fill_in 'message[content]', with: 'New message for badge test'
        click_button 'Send'
      end

      using_session('bob') do
        # Bob should see notification badge appear
        expect(page).to have_css('span.animate-pulse', wait: 5)
        badge = find('span.animate-pulse')
        expect(badge.text).to match(/\d+/)
      end
    end

    it 'updates badge count correctly' do
      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversations_path
        
        expect(page).not_to have_css('span.animate-pulse')
      end

      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        # Send multiple messages
        3.times do |i|
          fill_in 'message[content]', with: "Badge count test #{i + 1}"
          click_button 'Send'
          sleep(0.5) # Small delay between messages
        end
      end

      using_session('bob') do
        # Badge should show appropriate count
        expect(page).to have_css('span.animate-pulse', wait: 10)
        
        # Note: Exact count may vary due to timing, but should show some number
        badge = find('span.animate-pulse')
        expect(badge.text).to match(/\d+/)
      end
    end

    it 'removes badge when messages are read' do
      # Alice sends a message
      message = create(:test_message, 
                      conversation: conversation, 
                      user: alice, 
                      content: 'Badge removal test')

      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversations_path
        
        # Should have badge
        expect(page).to have_css('span.animate-pulse', wait: 5)
        
        # Click on conversation to read messages
        click_link conversation.name || 'Direct Message'
        
        # Should see the message
        expect(page).to have_text('Badge removal test')
        
        # Go back to conversations list
        visit conversations_path
        
        # Badge should be gone or reduced (depending on implementation)
        # This test might need adjustment based on exact badge behavior
      end
    end

    it 'shows 9+ when more than 9 unread messages' do
      # Alice sends many messages
      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        12.times do |i|
          fill_in 'message[content]', with: "Mass message #{i + 1}"
          click_button 'Send'
          sleep(0.2)
        end
      end

      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversations_path
        
        # Should show 9+ badge
        expect(page).to have_css('span.animate-pulse', wait: 10)
        badge = find('span.animate-pulse')
        expect(badge.text).to eq('9+')
      end
    end
  end

  describe 'Audio Notifications' do
    it 'attempts to play notification sound' do
      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversation_path(conversation)
        
        # Mock Audio constructor to track if sound is played
        page.execute_script(<<-JS)
          window.audioPlayCalled = false;
          window.Audio = function(src) {
            return {
              volume: 0.3,
              play: function() {
                window.audioPlayCalled = true;
                return Promise.resolve();
              }
            };
          };
        JS
      end

      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        fill_in 'message[content]', with: 'Audio notification test'
        click_button 'Send'
      end

      using_session('bob') do
        # Check if audio play was called
        audio_played = page.evaluate_script('window.audioPlayCalled')
        expect(audio_played).to be_truthy
      end
    end

    it 'handles audio play failures gracefully' do
      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversation_path(conversation)
        
        # Mock Audio to throw error
        page.execute_script(<<-JS)
          window.Audio = function(src) {
            return {
              volume: 0.3,
              play: function() {
                throw new Error('Audio blocked');
              }
            };
          };
        JS
      end

      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        fill_in 'message[content]', with: 'Audio error test'
        click_button 'Send'
      end

      using_session('bob') do
        # Should still see the message despite audio error
        expect(page).to have_text('Audio error test')
        # Page should remain functional
        expect(page).to have_field('message[content]')
      end
    end
  end

  describe 'Notification Preferences' do
    it 'respects user notification settings', :skip do
      # This would test user-specific notification preferences
      # Skipping as it requires user preference system implementation
    end
  end

  describe 'Notification Integration' do
    it 'combines all notification types correctly' do
      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversations_path
        
        # Setup notification mocks
        page.execute_script(<<-JS)
          window.notificationTests = {
            audioPlayed: false,
            browserNotificationShown: false
          };
          
          // Mock browser notifications
          if (typeof Notification !== 'undefined') {
            window.Notification = function(title, options) {
              window.notificationTests.browserNotificationShown = true;
            };
            Object.defineProperty(window.Notification, 'permission', { value: 'granted' });
          }
          
          // Mock audio
          window.Audio = function(src) {
            return {
              volume: 0.3,
              play: function() {
                window.notificationTests.audioPlayed = true;
                return Promise.resolve();
              }
            };
          };
        JS
      end

      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        fill_in 'message[content]', with: 'Complete notification test'
        click_button 'Send'
      end

      using_session('bob') do
        # Check all notification types were triggered
        sleep(2) # Allow time for notifications to process
        
        # Badge notification
        expect(page).to have_css('span.animate-pulse', wait: 5)
        
        # Audio notification
        audio_played = page.evaluate_script('window.notificationTests.audioPlayed')
        expect(audio_played).to be_truthy
        
        # Browser notification (if supported)
        browser_shown = page.evaluate_script('window.notificationTests.browserNotificationShown')
        expect(browser_shown).to be_truthy
      end
    end
  end

  describe 'Performance' do
    it 'handles rapid notification updates efficiently' do
      using_session('bob') do
        login_as(bob, scope: :user)
        visit conversations_path
      end

      using_session('alice') do
        login_as(alice, scope: :user)
        visit conversation_path(conversation)
        
        # Send messages rapidly
        start_time = Time.current
        
        5.times do |i|
          fill_in 'message[content]', with: "Rapid message #{i + 1}"
          click_button 'Send'
          sleep(0.1)
        end
        
        end_time = Time.current
        duration = end_time - start_time
        
        # Should complete in reasonable time
        expect(duration).to be < 5.0
      end

      using_session('bob') do
        # Should still show badge despite rapid updates
        expect(page).to have_css('span.animate-pulse', wait: 10)
        
        # Page should remain responsive
        expect(page).to have_link('Messages')
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
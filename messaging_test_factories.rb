# Enhanced Factories for Messaging System Testing
# This file contains comprehensive factories for testing the messaging system

FactoryBot.define do
  # User Factory
  factory :test_user, class: 'User' do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "Test User #{n}" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :member }
    last_seen_at { 1.minute.ago }

    trait :admin do
      role { :admin }
    end

    trait :moderator do
      role { :moderator }
    end

    trait :online do
      last_seen_at { 1.minute.ago }
    end

    trait :offline do
      last_seen_at { 1.hour.ago }
    end

    trait :away do
      last_seen_at { 10.minutes.ago }
    end

    # Consistent test users
    factory :alice do
      email { "alice@example.com" }
      name { "Alice Johnson" }
    end

    factory :bob do
      email { "bob@example.com" }
      name { "Bob Smith" }
    end

    factory :charlie do
      email { "charlie@example.com" }
      name { "Charlie Brown" }
    end
  end

  # Enhanced Message Factory
  factory :test_message, class: 'Message' do
    association :conversation, factory: :test_conversation
    association :user, factory: :test_user
    content { "Test message content" }
    message_type { :text }
    delivery_status { :sent }

    trait :with_reply do
      association :reply_to, factory: :test_message
    end

    trait :delivered do
      delivery_status { :delivered }
    end

    trait :read do
      delivery_status { :read }
    end

    trait :system_message do
      message_type { :system }
      content { "System notification message" }
    end

    # Quick test messages
    factory :simple_message do
      content { "Hello, this is a test message!" }
    end

    factory :reply_message do
      content { "This is a reply to your message" }
      association :reply_to, factory: :test_message
    end
  end

  # Enhanced Conversation Factory
  factory :test_conversation, class: 'Conversation' do
    name { "Test Conversation" }
    conversation_type { :direct_message }
    association :created_by, factory: :test_user

    trait :group_chat do
      conversation_type { :group_chat }
      name { "Test Group Chat" }
    end

    trait :direct_message do
      conversation_type { :direct_message }
      name { nil }
    end

    # Factory for conversations with users
    factory :conversation_with_users do
      transient do
        users_count { 2 }
      end

      after(:create) do |conversation, evaluator|
        create_list(:test_user_conversation, evaluator.users_count, conversation: conversation)
      end
    end

    # Factory for group conversation
    factory :group_conversation do
      conversation_type { :group_chat }
      name { "Test Group" }
      
      transient do
        users_count { 3 }
      end

      after(:create) do |conversation, evaluator|
        create_list(:test_user_conversation, evaluator.users_count, conversation: conversation)
      end
    end
  end

  # Enhanced UserConversation Factory
  factory :test_user_conversation, class: 'UserConversation' do
    association :user, factory: :test_user
    association :conversation, factory: :test_conversation
    joined_at { 1.hour.ago }
    last_read_at { 30.minutes.ago }
    is_admin { false }
    is_muted { false }
    notification_enabled { true }

    trait :admin do
      is_admin { true }
    end

    trait :muted do
      is_muted { true }
    end

    trait :notifications_disabled do
      notification_enabled { false }
    end

    trait :recently_read do
      last_read_at { 1.minute.ago }
    end

    trait :unread do
      last_read_at { 1.day.ago }
    end

    trait :left do
      left_at { 1.hour.ago }
    end
  end
end
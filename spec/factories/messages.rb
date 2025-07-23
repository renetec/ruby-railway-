FactoryBot.define do
  factory :message do
    conversation { nil }
    user { nil }
    content { "MyText" }
    message_type { 1 }
    delivery_status { 1 }
    edited_at { "2025-07-21 22:02:03" }
  end
end

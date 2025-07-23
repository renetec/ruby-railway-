FactoryBot.define do
  factory :user_conversation do
    user { nil }
    conversation { nil }
    joined_at { "2025-07-21 22:01:56" }
    left_at { "2025-07-21 22:01:56" }
    last_read_at { "2025-07-21 22:01:56" }
    is_admin { false }
    is_muted { false }
    notification_enabled { false }
  end
end

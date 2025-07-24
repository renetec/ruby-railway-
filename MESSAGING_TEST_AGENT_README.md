# Messaging System Test Agent 🧪

A comprehensive automated testing suite for the messaging system that validates all functionality including real-time messaging, notifications, replies, and delete operations.

## 🚀 Quick Start

### Run All Tests
```bash
ruby run_messaging_tests.rb
```

### Run Specific Test Suites
```bash
# Unit tests only
ruby run_messaging_tests.rb --unit-only

# System tests only  
ruby run_messaging_tests.rb --system-only

# Test agent only
ruby run_messaging_tests.rb --agent-only

# Notification tests only
ruby run_messaging_tests.rb --notifications-only
```

### Run with Options
```bash
# Verbose output
ruby run_messaging_tests.rb --verbose

# Skip specific test types
ruby run_messaging_tests.rb --no-system --no-notifications
```

## 📋 Test Components

### 1. Enhanced Factories (`messaging_test_factories.rb`)
Comprehensive FactoryBot factories for creating test data:
- **Users**: Alice, Bob, Charlie with different traits (online, offline, admin)
- **Messages**: Text, reply, system messages with attachments
- **Conversations**: Direct messages and group chats
- **UserConversations**: With various states (muted, admin, unread)

### 2. Unit Tests (`enhanced_message_spec.rb`)
Thorough testing of the Message model:
- ✅ Associations and validations
- ✅ Enums and scopes
- ✅ Callbacks and broadcasting
- ✅ Reply functionality
- ✅ Message types and delivery status
- ✅ Read tracking and attachments

### 3. System Tests (`messaging_system_spec.rb`)
End-to-end browser testing:
- ✅ Real-time message sending/receiving
- ✅ Reply functionality with threading
- ✅ Message deletion with permissions
- ✅ UI/UX features (styling, scrolling, auto-resize)
- ✅ Multi-browser concurrent testing

### 4. Notification Tests (`notification_system_spec.rb`)
Comprehensive notification system testing:
- ✅ Browser notifications and permissions
- ✅ Badge counters and updates
- ✅ Audio notifications
- ✅ Notification preferences
- ✅ Performance under load

### 5. Test Agent (`messaging_test_agent.rb`)
Automated testing scenarios:
- ✅ Basic messaging workflows
- ✅ Reply and delete functionality
- ✅ Notification system validation
- ✅ Real-time feature testing
- ✅ Performance benchmarking
- ✅ Concurrent user simulation
- ✅ Error handling verification

## 📊 Test Coverage

### Core Features Tested
| Feature | Unit Tests | System Tests | Agent Tests | Notification Tests |
|---------|------------|-------------|-------------|-------------------|
| Send/Receive Messages | ✅ | ✅ | ✅ | - |
| Reply Threading | ✅ | ✅ | ✅ | - |
| Message Deletion | ✅ | ✅ | ✅ | - |
| Real-time Updates | ✅ | ✅ | ✅ | - |
| Browser Notifications | - | ✅ | ✅ | ✅ |
| Badge Counters | ✅ | ✅ | ✅ | ✅ |
| Audio Notifications | - | - | - | ✅ |
| User Permissions | ✅ | ✅ | ✅ | - |
| Error Handling | ✅ | ✅ | ✅ | ✅ |
| Performance | - | ✅ | ✅ | ✅ |

### Test Scenarios Covered

#### 🔥 Core Messaging
- User A sends message to User B
- Real-time message delivery
- Message persistence and retrieval
- Multi-user conversations

#### 💬 Reply System
- Reply to specific messages
- Reply threading and references
- Nested reply chains
- Reply notifications

#### 🗑️ Message Management
- Delete own messages
- Permission restrictions
- Real-time deletion updates
- Cascade handling

#### 🔔 Notifications
- Browser notification requests
- Badge counter updates
- Audio notification playback
- Permission handling

#### ⚡ Performance
- 100+ message creation
- Concurrent user simulation
- Real-time update performance
- Memory usage optimization

#### 🛠️ Error Handling
- Network disconnections
- Server errors
- Invalid data handling
- Graceful degradation

## 🎯 Usage Examples

### Running Individual Test Components

#### Unit Tests Only
```ruby
# Load the enhanced test factories
require_relative 'messaging_test_factories'

# Run specific unit tests
RSpec.describe Message do
  it 'creates messages with factories' do
    message = create(:test_message, content: 'Test message')
    expect(message).to be_valid
  end
end
```

#### Test Agent Programmatically
```ruby
require_relative 'messaging_test_agent'

# Create and run agent
agent = MessagingTestAgent.new
results = agent.run_all_tests

# Check results
if results[:failed] == 0
  puts "✅ All messaging tests passed!"
else
  puts "❌ #{results[:failed]} tests failed"
end
```

#### System Tests with Custom Scenarios
```ruby
RSpec.describe 'Custom Messaging Scenario', type: :system do
  it 'handles complex conversation flow' do
    alice = create(:alice)
    bob = create(:bob)
    
    # Test your custom scenario here
  end
end
```

## 📈 Performance Benchmarks

The test agent includes performance benchmarking:

- **Message Creation**: 100 messages in < 5 seconds
- **Concurrent Users**: 3 users sending 5 messages each simultaneously
- **Real-time Updates**: Sub-second message delivery
- **Notification Processing**: Handles rapid notification updates

## 🔧 Configuration

### Test Environment Setup
```ruby
# In test database setup
User.create!(email: 'alice@example.com', name: 'Alice Johnson', password: 'password123')
User.create!(email: 'bob@example.com', name: 'Bob Smith', password: 'password123')
```

### Browser Configuration
```ruby
# For system tests
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end
end
```

## 🚨 Troubleshooting

### Common Issues

#### Permission Denied Errors
If you get permission errors, ensure proper file ownership:
```bash
sudo chown -R $(whoami):$(whoami) spec/
```

#### ActionCable Connection Issues
Ensure Redis is running for ActionCable:
```bash
redis-server
```

#### Browser Driver Issues
Install ChromeDriver for system tests:
```bash
# Ubuntu/Debian
sudo apt-get install chromium-chromedriver

# macOS
brew install chromedriver
```

#### Database Setup
Ensure test database is properly configured:
```bash
RAILS_ENV=test rails db:create db:migrate
```

### Debug Mode
Run tests with verbose output for debugging:
```bash
ruby run_messaging_tests.rb --verbose
```

## 📝 Adding Custom Tests

### Creating New Test Scenarios
1. Add new factories to `messaging_test_factories.rb`
2. Create test specs following existing patterns
3. Add scenarios to `messaging_test_agent.rb`
4. Update `run_messaging_tests.rb` if needed

### Example Custom Test
```ruby
# In messaging_test_agent.rb
def run_custom_scenario_tests
  test_section("Custom Scenario") do
    # Your custom test logic here
    conversation = create_test_conversation
    # ... test implementation
    
    record_test_result("Custom scenario", true)
  end
end
```

## 🎉 Success Metrics

A successful test run should show:
- ✅ All unit tests passing
- ✅ All system tests passing  
- ✅ All notification tests passing
- ✅ Test agent 100% success rate
- ✅ Performance benchmarks within limits
- ✅ Zero errors or exceptions

## 📞 Support

If you encounter issues with the test agent:

1. Check the troubleshooting section above
2. Run with `--verbose` flag for detailed output
3. Review the generated test reports
4. Check Rails logs for backend errors
5. Verify browser console for frontend issues

The test agent provides comprehensive validation of your messaging system and should catch any regressions or issues before they reach production! 🚀
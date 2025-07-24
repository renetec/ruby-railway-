require 'rails_helper'
require_relative 'messaging_test_factories'

RSpec.describe Message, type: :model do
  # Test associations
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:conversation) }
    it { should belong_to(:reply_to).class_name('Message').optional }
    it { should have_many(:replies).class_name('Message') }
  end

  # Test validations
  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:conversation) }
    
    context 'content validation' do
      it 'is valid with content' do
        message = build(:test_message, content: 'Test message')
        expect(message).to be_valid
      end

      it 'is valid without content if has attachments' do
        message = build(:test_message, :with_images, content: nil)
        expect(message).to be_valid
      end

      it 'is invalid without content and attachments' do
        message = build(:test_message, content: nil)
        expect(message).not_to be_valid
      end
    end
  end

  # Test enums
  describe 'enums' do
    it { should define_enum_for(:message_type).with_values(text: 0, image: 1, file: 2, system: 3) }
    it { should define_enum_for(:delivery_status).with_values(sent: 0, delivered: 1, read: 2) }
  end

  # Test scopes
  describe 'scopes' do
    let!(:old_message) { create(:test_message, created_at: 2.days.ago) }
    let!(:new_message) { create(:test_message, created_at: 1.hour.ago) }

    describe '.recent' do
      it 'orders messages by created_at descending' do
        expect(Message.recent).to eq([new_message, old_message])
      end
    end
  end

  # Test callbacks
  describe 'callbacks' do
    describe 'after_create_commit' do
      it 'broadcasts to conversation channel' do
        conversation = create(:test_conversation)
        user = create(:test_user)
        
        expect(ConversationChannel).to receive(:broadcast_to).with(
          conversation,
          hash_including(
            type: 'new_message',
            sender_id: user.id,
            sender_name: user.name
          )
        )
        
        create(:test_message, conversation: conversation, user: user)
      end
    end

    describe 'after_update_commit' do
      it 'broadcasts status update when delivery status changes' do
        message = create(:test_message, delivery_status: :sent)
        
        expect(ConversationChannel).to receive(:broadcast_to).with(
          message.conversation,
          hash_including(
            type: 'message_status_update',
            message_id: message.id,
            status: 'delivered'
          )
        )
        
        message.update(delivery_status: :delivered)
      end

      it 'does not broadcast when other attributes change' do
        message = create(:test_message)
        
        expect(ConversationChannel).not_to receive(:broadcast_to)
        
        message.update(content: 'Updated content')
      end
    end
  end

  # Test instance methods
  describe '#has_attachments?' do
    it 'returns false for message without attachments' do
      message = build(:test_message)
      expect(message.has_attachments?).to be false
    end

    it 'returns true for message with images' do
      message = build(:test_message, :with_images)
      expect(message.has_attachments?).to be true
    end

    it 'returns true for message with file' do
      message = build(:test_message, :with_file)
      expect(message.has_attachments?).to be true
    end
  end

  describe '#mark_as_read_by' do
    let(:message) { create(:test_message) }
    let(:user) { create(:test_user) }

    it 'adds user to read_by list' do
      message.mark_as_read_by(user)
      expect(message.reload.read_by).to include(user.id)
    end

    it 'does not add user twice' do
      message.mark_as_read_by(user)
      message.mark_as_read_by(user)
      expect(message.reload.read_by.count(user.id)).to eq(1)
    end

    it 'handles nil read_by array' do
      message.update_column(:read_by, nil)
      expect { message.mark_as_read_by(user) }.not_to raise_error
      expect(message.reload.read_by).to include(user.id)
    end
  end

  # Test reply functionality
  describe 'reply functionality' do
    let(:original_message) { create(:test_message, content: 'Original message') }
    let(:reply) { create(:reply_message, reply_to: original_message) }

    it 'can create a reply to a message' do
      expect(reply.reply_to).to eq(original_message)
      expect(original_message.replies).to include(reply)
    end

    it 'allows nil reply_to for non-reply messages' do
      message = create(:test_message, reply_to: nil)
      expect(message).to be_valid
      expect(message.reply_to).to be_nil
    end
  end

  # Test message types
  describe 'message types' do
    it 'creates text message by default' do
      message = create(:test_message)
      expect(message).to be_text
    end

    it 'creates system message' do
      message = create(:test_message, :system_message)
      expect(message).to be_system
      expect(message.content).to eq('System notification message')
    end

    it 'creates image message with attachments' do
      message = create(:test_message, :with_images)
      expect(message).to be_image
      expect(message.images).to be_attached
    end

    it 'creates file message with attachment' do
      message = create(:test_message, :with_file)
      expect(message).to be_file
      expect(message.file).to be_attached
    end
  end

  # Test delivery status
  describe 'delivery status' do
    it 'defaults to sent status' do
      message = create(:test_message)
      expect(message).to be_sent
    end

    it 'can be marked as delivered' do
      message = create(:test_message, :delivered)
      expect(message).to be_delivered
    end

    it 'can be marked as read' do
      message = create(:test_message, :read)
      expect(message).to be_read
    end
  end

  # Test broadcasting methods
  describe 'broadcasting methods' do
    let(:message) { create(:test_message) }

    describe '#broadcast_to_conversation' do
      it 'handles broadcast errors gracefully' do
        allow(ConversationChannel).to receive(:broadcast_to).and_raise(StandardError.new('Broadcast failed'))
        allow(Rails.logger).to receive(:error)
        
        expect { message.send(:broadcast_to_conversation) }.not_to raise_error
        expect(Rails.logger).to have_received(:error).with('Message broadcast failed: Broadcast failed')
      end
    end
  end

  # Integration tests
  describe 'integration scenarios' do
    let(:alice) { create(:alice) }
    let(:bob) { create(:bob) }
    let(:conversation) { create(:test_conversation) }

    before do
      create(:test_user_conversation, user: alice, conversation: conversation)
      create(:test_user_conversation, user: bob, conversation: conversation)
    end

    it 'handles complete messaging scenario' do
      # Alice sends a message
      original = create(:test_message, 
                       conversation: conversation, 
                       user: alice, 
                       content: 'Hello Bob!')
      
      # Bob replies
      reply = create(:reply_message, 
                    conversation: conversation,
                    user: bob, 
                    reply_to: original,
                    content: 'Hello Alice!')
      
      # Verify the conversation structure
      expect(conversation.messages.count).to eq(2)
      expect(original.replies).to include(reply)
      expect(reply.reply_to).to eq(original)
      
      # Bob marks Alice's message as read
      original.mark_as_read_by(bob)
      expect(original.read_by).to include(bob.id)
    end

    it 'handles message deletion scenario' do
      message = create(:test_message, 
                      conversation: conversation, 
                      user: alice)
      
      message_id = message.id
      message.destroy
      
      expect { Message.find(message_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
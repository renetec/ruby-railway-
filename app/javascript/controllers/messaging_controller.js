import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["messages", "input", "typingIndicator", "replyPreview", "replyAuthor", "replyContent", "replyToField", "emojiPicker", "fileInput", "filePreview", "fileList"]
  static values = { conversationId: Number, userId: Number }

  connect() {
    this.subscription = consumer.subscriptions.create(
      { 
        channel: "ConversationChannel", 
        conversation_id: this.conversationIdValue 
      },
      {
        received: (data) => this.handleReceived(data),
        speak: (content) => this.perform("speak", { content }),
        startTyping: () => this.perform("start_typing"),
        stopTyping: () => this.perform("stop_typing")
      }
    )

    this.setupTypingIndicators()
    this.styleExistingMessages()
    this.ensureButtonVisibility()
    this.scrollToBottom()
    this.requestNotificationPermission()
    
    // Add outside click listener for emoji picker
    document.addEventListener('click', this.handleOutsideClick)
  }

  disconnect() {
    this.subscription?.unsubscribe()
    clearTimeout(this.typingTimer)
  }

  sendMessage(event) {
    event.preventDefault()
    const content = this.inputTarget.value.trim()
    const files = this.fileInputTarget.files
    
    if (content || files.length > 0) {
      if (files.length > 0) {
        // Send message with files via form submission
        this.sendMessageWithFiles()
      } else {
        // Send text-only message via ActionCable
        const replyToId = this.replyToFieldTarget.value
        
        const messageData = {
          content: content,
          reply_to_message_id: replyToId || null
        }
        
        this.subscription.perform('speak', messageData)
        this.inputTarget.value = ""
        this.cancelReply()
        this.subscription.perform('stop_typing')
      }
    }
  }

  sendMessageWithFiles() {
    const form = this.element.querySelector('form')
    const formData = new FormData(form)
    
    fetch(form.action, {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.inputTarget.value = ""
        this.clearFiles()
        this.cancelReply()
      } else {
        alert('Error sending message with files')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert('Error sending message')
    })
  }

  handleReceived(data) {
    switch(data.type) {
      case 'new_message':
        // Show all messages - no filtering
        if (data.message) {
          // Old format - HTML already rendered
          this.appendMessage(data.message)
        } else if (data.message_data) {
          // New format - render from data
          this.renderAndAppendMessage(data.message_data)
        }
        
        // Only notifications for messages from others
        if (data.sender_id !== this.userIdValue) {
          this.playNotificationSound()
          this.showBrowserNotification(data.sender_name, data.message_content)
          this.updateMessagesBadge()
        }
        break
      case 'typing_indicator':
        this.updateTypingIndicator(data)
        break
      case 'presence_update':
        this.updateUserPresence(data)
        break
      case 'message_status_update':
        this.updateMessageStatus(data)
        break
      case 'message_deleted':
        console.log('Received message_deleted broadcast:', data)
        this.removeMessage(data.message_id)
        break
    }
  }

  setupTypingIndicators() {
    this.inputTarget.addEventListener('input', () => {
      this.subscription.perform('start_typing')
      
      clearTimeout(this.typingTimer)
      this.typingTimer = setTimeout(() => {
        this.subscription.perform('stop_typing')
      }, 1000)
    })
  }

  autoResize() {
    const textarea = this.inputTarget
    textarea.style.height = 'auto'
    textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px'
  }

  handleInput() {
    this.autoResize()
  }

  appendMessage(messageHTML) {
    this.messagesTarget.insertAdjacentHTML('beforeend', messageHTML)
    
    // Find the newly added message and style it based on current user
    const newMessages = this.messagesTarget.querySelectorAll('.message-wrapper:not([data-styled])')
    newMessages.forEach(messageElement => {
      const senderId = parseInt(messageElement.dataset.senderId)
      const isCurrentUser = senderId === this.userIdValue
      
      if (isCurrentUser) {
        messageElement.className = 'message-wrapper flex justify-end'
        const content = messageElement.querySelector('.message-content')
        content.className = 'message-content max-w-md bg-blue-500 text-white rounded-lg p-3 shadow'
        
        // Update text colors for current user messages
        const nameElement = content.querySelector('.text-gray-600')
        if (nameElement) nameElement.className = 'text-xs font-semibold mb-1 text-blue-100'
        
        const timeElement = content.querySelector('.text-gray-500')
        if (timeElement) timeElement.className = 'text-xs text-blue-100'
        
        const replyBtn = content.querySelector('.reply-btn')
        if (replyBtn) replyBtn.className = 'reply-btn text-xs text-blue-100 hover:text-white transition-colors'
        
        const deleteBtn = content.querySelector('.delete-btn')
        if (deleteBtn) {
          deleteBtn.className = 'delete-btn text-xs text-red-300 hover:text-red-100 transition-colors'
          deleteBtn.style.display = 'inline' // Make sure it's visible for current user
        }
        
        // Hide sender name for current user
        if (nameElement) nameElement.style.display = 'none'
      } else {
        messageElement.className = 'message-wrapper flex justify-start'
        
        // Hide delete button for messages from other users
        const deleteBtn = messageElement.querySelector('.delete-btn')
        if (deleteBtn) {
          deleteBtn.style.display = 'none'
          deleteBtn.setAttribute('data-hidden', 'true')
        }
      }
      
      messageElement.setAttribute('data-styled', 'true')
    })
    
    this.ensureButtonVisibility()
    this.scrollToBottom()
  }

  renderAndAppendMessage(messageData) {
    const isCurrentUser = messageData.user_id === this.userIdValue
    const messageWrapper = document.createElement('div')
    messageWrapper.className = `message-wrapper ${isCurrentUser ? 'flex justify-end' : 'flex justify-start'}`
    messageWrapper.setAttribute('data-message-id', messageData.id)
    
    if (messageData.optimistic) {
      messageWrapper.setAttribute('data-optimistic', 'true')
    }

    const messageContent = document.createElement('div')
    messageContent.className = `message-content max-w-md ${isCurrentUser ? 'bg-blue-500 text-white' : 'bg-white'} rounded-lg p-3 shadow`

    let html = ''
    
    // Add sender name for non-current user messages
    if (!isCurrentUser) {
      html += `<p class="text-xs font-semibold mb-1 text-gray-600">${messageData.user_name}</p>`
    }
    
    // Add reply reference if present
    if (messageData.reply_to) {
      html += `
        <div class="reply-reference text-xs p-2 mb-2 rounded ${isCurrentUser ? 'bg-blue-600' : 'bg-gray-100'}">
          <p class="font-semibold">${messageData.reply_to.user.name}</p>
          <p class="truncate">${messageData.reply_to.content}</p>
        </div>
      `
    }
    
    // Add message content
    html += `<p class="message-text">${messageData.content}</p>`
    
    // Add timestamp and reply button
    html += `
      <div class="flex items-center justify-between mt-2">
        <p class="text-xs ${isCurrentUser ? 'text-blue-100' : 'text-gray-500'}">
          ${messageData.created_at}
        </p>
        <div class="flex items-center space-x-2">
          <button class="reply-btn text-xs ${isCurrentUser ? 'text-blue-100 hover:text-white' : 'text-gray-500 hover:text-gray-700'} transition-colors"
                  data-action="messaging#startReply"
                  data-messaging-message-id="${messageData.id}"
                  data-messaging-author-name="${messageData.user_name}"
                  data-messaging-content="${messageData.content}">
            Répondre
          </button>
          
          <button class="delete-btn text-xs text-red-500 hover:text-red-700 transition-colors bg-red-100 px-2 py-1 rounded"
                  data-action="messaging#deleteMessage"
                  data-messaging-message-id="${messageData.id}"
                  data-messaging-user-id="${messageData.user_id}">
            🗑️ Supprimer
          </button>
        </div>
      </div>
    `
    
    messageContent.innerHTML = html
    messageWrapper.appendChild(messageContent)
    this.messagesTarget.appendChild(messageWrapper)
    this.scrollToBottom()
  }

  removeMessage(messageId) {
    console.log('Attempting to remove message:', messageId)
    const messageElement = document.querySelector(`[data-message-id="${messageId}"]`)
    if (messageElement) {
      console.log('Found message element, removing:', messageElement)
      messageElement.style.transition = 'opacity 0.3s ease'
      messageElement.style.opacity = '0'
      setTimeout(() => {
        messageElement.remove()
        console.log('Message removed from DOM')
      }, 300)
    } else {
      console.log('Message element not found for ID:', messageId)
    }
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  updateTypingIndicator(data) {
    if (data.user_id === this.userIdValue) return
    
    const indicator = this.typingIndicatorTarget
    if (data.typing) {
      indicator.textContent = `${data.username} is typing...`
      indicator.classList.remove('hidden')
    } else {
      indicator.classList.add('hidden')
    }
  }

  updateUserPresence(data) {
    const userElement = document.querySelector(`[data-user-id="${data.user_id}"]`)
    if (userElement) {
      const statusIndicator = userElement.querySelector('.online-status')
      if (statusIndicator) {
        if (data.online) {
          statusIndicator.classList.add('bg-green-400')
          statusIndicator.classList.remove('bg-gray-400')
        } else {
          statusIndicator.classList.add('bg-gray-400')
          statusIndicator.classList.remove('bg-green-400')
        }
      }
    }
  }

  updateMessageStatus(data) {
    const messageElement = document.querySelector(`[data-message-id="${data.message_id}"]`)
    if (messageElement) {
      const statusElement = messageElement.querySelector('.message-status')
      if (statusElement) {
        statusElement.textContent = data.status
      }
    }
  }

  playNotificationSound() {
    // Play subtle notification sound
    const audio = new Audio('/sounds/notification.mp3')
    audio.volume = 0.3
    audio.play().catch(() => {}) // Fail silently if audio blocked
  }

  showBrowserNotification(senderName, messageContent) {
    // Request permission for notifications
    if (Notification.permission === 'granted') {
      new Notification(`Nouveau message de ${senderName}`, {
        body: messageContent.substring(0, 100) + (messageContent.length > 100 ? '...' : ''),
        icon: '/favicon.ico',
        tag: 'message-notification'
      })
    } else if (Notification.permission === 'default') {
      Notification.requestPermission().then(permission => {
        if (permission === 'granted') {
          this.showBrowserNotification(senderName, messageContent)
        }
      })
    }
  }

  updateMessagesBadge() {
    // Update the messages badge in navigation
    const badge = document.querySelector('.nav-link .animate-pulse')
    if (badge) {
      const currentCount = parseInt(badge.textContent) || 0
      const newCount = currentCount + 1
      badge.textContent = newCount > 9 ? '9+' : newCount.toString()
      badge.classList.add('animate-pulse')
    } else {
      // Create a new badge if none exists
      const messagesLink = document.querySelector('a[href*="conversations"]')
      if (messagesLink && !messagesLink.querySelector('.animate-pulse')) {
        const newBadge = document.createElement('span')
        newBadge.className = 'absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center font-bold animate-pulse'
        newBadge.textContent = '1'
        messagesLink.style.position = 'relative'
        messagesLink.appendChild(newBadge)
      }
    }
  }

  requestNotificationPermission() {
    if ('Notification' in window && Notification.permission === 'default') {
      Notification.requestPermission()
    }
  }

  startReply(event) {
    const button = event.currentTarget
    const messageId = button.dataset.messagingMessageId
    const authorName = button.dataset.messagingAuthorName
    const content = button.dataset.messagingContent

    // Set reply data
    this.replyToFieldTarget.value = messageId
    this.replyAuthorTarget.textContent = authorName
    this.replyContentTarget.textContent = content

    // Show reply preview
    this.replyPreviewTarget.classList.remove('hidden')
    
    // Focus on input
    this.inputTarget.focus()
  }

  cancelReply() {
    // Clear reply data
    this.replyToFieldTarget.value = ""
    this.replyAuthorTarget.textContent = ""
    this.replyContentTarget.textContent = ""

    // Hide reply preview
    this.replyPreviewTarget.classList.add('hidden')
  }

  deleteMessage(event) {
    console.log('Delete button clicked!')
    const button = event.currentTarget
    const messageId = button.dataset.messagingMessageId
    const messageUserId = parseInt(button.dataset.messagingUserId)
    
    // Allow deletion of any message in the conversation
    if (confirm('Êtes-vous sûr de vouloir supprimer ce message?')) {
      // Send delete request via fetch to the messages controller
      fetch(`/conversations/${this.conversationIdValue}/messages/${messageId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      .then(response => {
        if (response.ok) {
          console.log('Delete request successful')
          // Remove the message immediately for better UX
          this.removeMessage(messageId)
        } else {
          alert('Erreur lors de la suppression du message')
        }
      })
      .catch(error => {
        console.error('Delete request failed:', error)
        alert('Erreur lors de la suppression du message')
      })
    }
  }

  getReplyToData(replyToId) {
    // Find the original message element to get reply data
    const originalMessage = document.querySelector(`[data-message-id="${replyToId}"]`)
    if (originalMessage) {
      const authorName = this.replyAuthorTarget.textContent
      const content = this.replyContentTarget.textContent
      return {
        user: { name: authorName },
        content: content
      }
    }
    return null
  }

  removeOptimisticMessage() {
    // Remove the last optimistic message (temporary message we just sent)
    const optimisticMessages = this.messagesTarget.querySelectorAll('[data-optimistic="true"]')
    if (optimisticMessages.length > 0) {
      optimisticMessages[optimisticMessages.length - 1].remove()
    }
  }

  styleExistingMessages() {
    // Style all messages that are already on the page when it loads
    const existingMessages = this.messagesTarget.querySelectorAll('.message-wrapper')
    existingMessages.forEach(messageElement => {
      const senderId = parseInt(messageElement.dataset.senderId)
      const isCurrentUser = senderId === this.userIdValue
      
      if (isCurrentUser) {
        messageElement.className = 'message-wrapper flex justify-end'
        const content = messageElement.querySelector('.message-content')
        content.className = 'message-content max-w-md bg-blue-500 text-white rounded-lg p-3 shadow'
        
        // Update text colors for current user messages
        const nameElement = content.querySelector('.text-gray-600')
        if (nameElement) {
          nameElement.className = 'text-xs font-semibold mb-1 text-blue-100'
          nameElement.style.display = 'none' // Hide sender name for current user
        }
        
        const timeElement = content.querySelector('.text-gray-500')
        if (timeElement) timeElement.className = 'text-xs text-blue-100'
        
        const replyBtn = content.querySelector('.reply-btn')
        if (replyBtn) replyBtn.className = 'reply-btn text-xs text-blue-100 hover:text-white transition-colors'
        
        const deleteBtn = content.querySelector('.delete-btn')
        if (deleteBtn) {
          deleteBtn.className = 'delete-btn text-xs text-red-300 hover:text-red-100 transition-colors'
        }
      } else {
        messageElement.className = 'message-wrapper flex justify-start'
        
        // Show delete button for all messages (including from other users)
        const deleteBtn = messageElement.querySelector('.delete-btn')
        if (deleteBtn) {
          deleteBtn.style.display = 'inline'
          deleteBtn.className = 'delete-btn text-xs text-red-500 hover:text-red-700 transition-colors'
        }
      }
    })
  }

  ensureButtonVisibility() {
    // Force check all delete buttons after page load or after message deletion
    const allMessages = this.messagesTarget.querySelectorAll('.message-wrapper')
    allMessages.forEach(messageElement => {
      const senderId = parseInt(messageElement.dataset.senderId)
      const isCurrentUser = senderId === this.userIdValue
      const deleteBtn = messageElement.querySelector('.delete-btn')
      
      if (deleteBtn) {
        // Show delete button for all messages
        deleteBtn.style.display = 'inline'
        deleteBtn.removeAttribute('data-hidden')
      }
    })
  }

  // Emoji picker methods
  toggleEmojiPicker(event) {
    event.preventDefault()
    this.emojiPickerTarget.classList.toggle('hidden')
  }

  insertEmoji(event) {
    event.preventDefault()
    const emoji = event.currentTarget.dataset.emoji
    const input = this.inputTarget
    const start = input.selectionStart
    const end = input.selectionEnd
    const text = input.value
    
    input.value = text.substring(0, start) + emoji + text.substring(end)
    input.setSelectionRange(start + emoji.length, start + emoji.length)
    input.focus()
    
    // Hide emoji picker after selection
    this.emojiPickerTarget.classList.add('hidden')
    
    // Auto-resize after adding emoji
    this.autoResize()
  }

  // File attachment methods
  openFileDialog(event) {
    event.preventDefault()
    this.fileInputTarget.click()
  }

  handleFileSelect(event) {
    const files = Array.from(event.target.files)
    if (files.length > 0) {
      this.displayFilePreview(files)
    }
  }

  displayFilePreview(files) {
    this.filePreviewTarget.classList.remove('hidden')
    this.fileListTarget.innerHTML = ''
    
    files.forEach((file, index) => {
      const fileItem = document.createElement('div')
      fileItem.className = 'file-item bg-white rounded px-2 py-1 border text-sm flex items-center space-x-2'
      
      // File icon based on type
      let icon = '📄'
      if (file.type.startsWith('image/')) {
        icon = '🖼️'
      } else if (file.type.includes('pdf')) {
        icon = '📄'
      } else if (file.type.includes('document') || file.type.includes('word')) {
        icon = '📝'
      } else if (file.type.includes('zip') || file.type.includes('rar')) {
        icon = '📦'
      }
      
      fileItem.innerHTML = `
        <span>${icon}</span>
        <span class="truncate max-w-[120px]">${file.name}</span>
        <span class="text-gray-500 text-xs">(${this.formatFileSize(file.size)})</span>
        <button type="button" 
                class="text-red-500 hover:text-red-700 ml-1"
                data-action="click->messaging#removeFile"
                data-file-index="${index}">
          ×
        </button>
      `
      
      this.fileListTarget.appendChild(fileItem)
    })
  }

  removeFile(event) {
    event.preventDefault()
    const fileIndex = parseInt(event.currentTarget.dataset.fileIndex)
    const files = Array.from(this.fileInputTarget.files)
    
    // Remove file from the list
    files.splice(fileIndex, 1)
    
    // Update file input
    const dt = new DataTransfer()
    files.forEach(file => dt.items.add(file))
    this.fileInputTarget.files = dt.files
    
    // Update preview
    if (files.length > 0) {
      this.displayFilePreview(files)
    } else {
      this.clearFiles()
    }
  }

  clearFiles(event) {
    if (event) event.preventDefault()
    this.fileInputTarget.value = ''
    this.filePreviewTarget.classList.add('hidden')
    this.fileListTarget.innerHTML = ''
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  // Close emoji picker when clicking outside
  disconnect() {
    this.subscription?.unsubscribe()
    clearTimeout(this.typingTimer)
    document.removeEventListener('click', this.handleOutsideClick)
  }

  handleOutsideClick = (event) => {
    if (!this.element.contains(event.target)) {
      this.emojiPickerTarget.classList.add('hidden')
    }
  }

  // File/Image interaction methods
  openImageModal(event) {
    const img = event.currentTarget
    const modal = document.createElement('div')
    modal.className = 'fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50'
    modal.innerHTML = `
      <div class="relative max-w-4xl max-h-full p-4">
        <img src="${img.src}" class="max-w-full max-h-full rounded-lg">
        <button class="absolute top-2 right-2 text-white hover:text-gray-300 text-2xl font-bold bg-black bg-opacity-50 rounded-full w-8 h-8 flex items-center justify-center"
                onclick="this.parentElement.parentElement.remove()">
          ×
        </button>
      </div>
    `
    
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.remove()
      }
    })
    
    document.body.appendChild(modal)
  }

  downloadFile(event) {
    event.preventDefault()
    const url = event.currentTarget.dataset.url
    const link = document.createElement('a')
    link.href = url
    link.download = ''
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }
}
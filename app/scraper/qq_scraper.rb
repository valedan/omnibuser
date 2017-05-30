class QQScraper < ForumScraper
  def get_story
    @css = {post: '#messageList .message',
            threadmark: '.message.hasThreadmark',
            overlay_threadmark: '.overlayScroll.threadmarks li',
            chapter_pub_date: '.messageInfo .messageMeta .datePermalink .DateTime',
            chapter_edit_date: '.messageInfo .editDate .DateTime',
            story_pub_date: '.message .primaryContent .messageMeta .datePermalink',
            avatar: '#messageList .message .avatar img',
            threadmark_list_item: '.threadmarkItem a',
            chapter_threadmark_text: 'Threadmark:',
            chapter_content: '.messageContent .messageText',
          }

    super
  end
end

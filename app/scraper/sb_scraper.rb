class SBScraper < ForumScraper
  def get_story
    @css = {post: '#messageList .message',
            threadmark: '.message.hasThreadmark',
            overlay_threadmark: '.overlayScroll.threadmarkList li',
            chapter_pub_date: '.messageInfo .messageMeta .datePermalink .DateTime',
            chapter_edit_date: '.messageInfo .editDate .DateTime',
            story_pub_date: '.message .primaryContent .messageMeta .datePermalink',
            avatar: '#messageList .message .avatar img',
            threadmark_list_item: '.threadmarkListItem a',
            chapter_threadmark_text: 'Threadmarks:',
            chapter_content: '.messageContent .messageText',
          }

    super
  end
end

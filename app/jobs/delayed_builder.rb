class DelayedBuilder
  @queue = :build

  def self.perform(request_id)
    request = Request.find(request_id)
    story = request.story
    begin
      doc_id = story.build(request.extension)
      request.update(doc_id: doc_id, complete: true, status: "Success")
    rescue Exception => e
      request.update(complete: true, status: e)
      raise e
    end
  end


end

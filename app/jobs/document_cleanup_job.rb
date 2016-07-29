class DocumentCleanupJob < ApplicationJob
  queue_as :default
  #need to setup a job backend for production
  def perform(doc)
    doc.destroy
  end
end

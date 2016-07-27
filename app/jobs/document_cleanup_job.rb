class DocumentCleanupJob < ApplicationJob
  queue_as :default

  def perform(doc)
    doc.destroy
  end
end

class DailyBackupJob < ApplicationJob
  queue_as :default

  def perform
    items = Item.where(:content_type => "SF|Extension")
    items.each do |item|
      content = item.decoded_content
      if content && content["frequency"] == "daily"
        ExtensionJob.perform_later(content["url"], item.user.items.to_a, item.user.auth_params)
      end
    end
  end

end

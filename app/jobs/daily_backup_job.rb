class DailyBackupJob < ApplicationJob
  queue_as :default

  def perform_rate_limited_send(queue, proc)
    jobs_per_second = 15
    current_delay = 0.0
    current_job_number = 0
    queue.each do |queue_item|
      if current_job_number > jobs_per_second
        current_job_number = 0
        current_delay += 1.2
      end
      current_job_number += 1
      proc.call(queue_item, current_delay)
    end
  end

  def perform
    queue = []
    items = Item.where(:content_type => "SF|Extension")
    items.each do |item|
      content = item.decoded_content
      if content && content["frequency"] == "daily"
        queue.push({
          url: content["url"],
          user: item.user,
          user_id: item.user && item.user.uuid
        })
      end
    end

    proc = Proc.new do |queue_item, delay|
      user = queue_item[:user]
      url = queue_item[:url]
      if user != nil
        ExtensionJob.set(wait: delay.seconds).perform_later(url, user.items.to_a, user.auth_params)
      else
        puts "User is nil, #{queue_item[:user_id]}"
      end
    end

    perform_rate_limited_send(queue, proc)
  end

end

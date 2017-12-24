class ArchiveMailer < ApplicationMailer

  def data_backup(user)
    date = Date.today

    data = {:items => user.items.where(:deleted => false), :auth_params => user.auth_params}
    attachments["SN-Data-#{date}.txt"] = {:mime_type => 'application/json', :content => JSON.pretty_generate(data.as_json({})) }
    mail(to: user.email, subject: "Data Backup for #{date}")
  end

  def export_archive(email)

  end

end

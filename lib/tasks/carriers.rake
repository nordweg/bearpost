namespace :carriers do
  desc "Every 3 hours"
  task check_for_updates: :environment do
    Rails.configuration.carriers.each do |carrier|
      p carrier.id
      p carrier.display_name
    end
  end
end

namespace :carriers do
  desc "Asks each carrier to check for updates"
  task check_for_updates: :environment do
    Rails.configuration.carriers.each do |carrier|
      carrier.check_for_updates
    end
  end
end

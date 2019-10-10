namespace :carriers do
  desc "Asks each carrier to check for updates"
  task check_for_updates: :environment do
    DeliveryStatusUpdater.update_all_shipments
  end
end

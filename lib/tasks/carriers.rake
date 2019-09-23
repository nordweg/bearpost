namespace :carriers do # REFACTOR > Not sure this is still needed. CarrierSyncronizer.update_all_shipments_delivery_status does the same
  desc "Asks each carrier to check for updates"
  task check_for_updates: :environment do
    CarrierSyncronizer.update_all_shipments_delivery_status
  end
end

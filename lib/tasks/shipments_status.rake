namespace :shipments_status do
  desc "Updates delivery status of all shipments with carriers"
  task update_all: :environment do
    CarrierSyncronizer.update_all_shipments_delivery_status
    puts "#{Time.now} — Success!"
  end

end

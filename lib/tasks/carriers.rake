namespace :carriers do
  desc "Asks each carrier to check for updates"
  task check_for_updates: :environment do
    Rails.configuration.carriers.each do |carrier|
      carrier.shipments.each do |shipment|
        puts "#{shipment.shipment_number} :"
        begin
          carrier.save_delivery_updates(shipment)
          puts "OK"
        rescue Exception => e
          puts "ERRO (#{carrier.name})"
          puts e.message
        end
        puts ""
      end
    end
  end
end

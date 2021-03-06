module Fog
  module Compute
    class AzureRM
      # This class is giving implementation of create/save and
      # delete/destroy for Managed Disk.
      class ManagedDisk < Fog::Model
        attribute :id
        identity  :name
        attribute :resource_group_name
        attribute :type
        attribute :location
        attribute :account_type
        attribute :time_created
        attribute :os_type
        attribute :disk_size_gb
        attribute :owner_id
        attribute :provisioning_state
        attribute :tags
        attribute :creation_data
        attribute :encryption_settings

        def self.parse(managed_disk)
          disk = get_hash_from_object(managed_disk)

          unless managed_disk.creation_data.nil?
            creation_data = Fog::Compute::AzureRM::CreationData.new
            disk['creation_data'] = creation_data.merge_attributes(Fog::Compute::AzureRM::CreationData.parse(managed_disk.creation_data))
          end

          unless managed_disk.encryption_settings.nil?
            encryption_settings = Fog::Compute::AzureRM::EncryptionSettings.new
            disk['encryption_settings'] = encryption_settings.merge_attributes(Fog::Compute::AzureRM::EncryptionSettings.parse(managed_disk.encryption_settings))
          end

          disk['resource_group_name'] = get_resource_group_from_id(managed_disk.id)

          disk
        end

        def save
          requires :name, :location, :resource_group_name, :creation_data
          requires :disk_size_gb if creation_data[:create_option] == 'Empty'
          validate_creation_data_params(creation_data)

          disk = service.create_or_update_managed_disk(managed_disk_params)
          merge_attributes(Fog::Compute::AzureRM::ManagedDisk.parse(disk))
        end

        def destroy
          service.delete_managed_disk(resource_group_name, name)
        end

        private

        def validate_creation_data_params(creation_data)
          unless creation_data.key?(:create_option)
            raise(ArgumentError, ':create_option is required for this operation')
          end
        end

        def managed_disk_params
          {
            name: name,
            location: location,
            resource_group_name: resource_group_name,
            account_type: account_type,
            os_type: os_type,
            disk_size_gb: disk_size_gb,
            tags: tags,
            creation_data: creation_data,
            encryption_settings: encryption_settings
          }
        end
      end
    end
  end
end

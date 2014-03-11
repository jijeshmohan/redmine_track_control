module RedmineTrackControl
  module  IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
            unloadable
            validate :is_tracker_valid, :on => :create
      end
    end

    module InstanceMethods
      private
        def is_tracker_valid
          return true if project.enabled_modules.where(:name => "tracker_permissions").count == 0
          tracker_permission_flag = "create_tracker#{self.tracker.id}".to_sym
          errors.add(:tracker_id, :invalid) if !User.current.allowed_to?(tracker_permission_flag, self.project, :global => true)
        end
    end
  end
end

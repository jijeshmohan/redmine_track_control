#Patches Redmine's Tracker. Adds callback to manipulate permission
module RedmineTrackControl
  module TrackerHelper
    def self.add_tracker_permission(tracker)
      Redmine::AccessControl.map {|map| map.project_module(:tracker_permissions) {|map|map.permission(permission(tracker), {:issues => :index}, {})}}
    end

    def self.remove_tracker_permission(tracker)
      perm = Redmine::AccessControl.permission(permission(tracker))
      Redmine::AccessControl.permissions.delete perm unless perm.nil?
    end

    def self.permission(tracker)
      "create_tracker#{tracker.id}".to_sym
    end
  end
end

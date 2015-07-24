# Helper module
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

    # Gets the list of valid trackers for the project for the current user
    def self.valid_trackers_list(project)
      if not project.nil?
        if project.enabled_modules.where(:name => "tracker_permissions").count == 1
          project.trackers.select{|t| User.current.allowed_to?(permission(t), project, :global => true)}.collect {|t| [t.name, t.id]}
        else
          project.trackers.collect {|t| [t.name, t.id]}
        end
      end
    end
  end
end

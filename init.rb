require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'tracker'
  Tracker.send(:include, RedmineTrackControl::TrackerPatch)

  require_dependency 'role'
  Role.send(:include, RedmineTrackControl::RolePatch)

  require_dependency 'issue'
  Issue.send(:include, RedmineTrackControl::IssuePatch)

  require_dependency 'roles_controller'
  RolesController.send(:include, RedmineTrackControl::RolesControllerPatch)

  require_dependency 'issues_controller'
  IssuesController.send(:include, RedmineTrackControl::IssuesControllerPatch)
end

Redmine::Plugin.register :redmine_track_control do
  name 'Redmine Tracker Control plugin'
  author 'Jijesh Mohan'
  description 'Plugin for controlling tracker wise issue creation'
  version '1.0.9'
  url 'https://github.com/jijeshmohan/redmine_track_control'
  author_url 'jijeshmohan.wordpress.com'

  project_module :tracker_permissions do
    Tracker.all.each do |t|
      permission "create_tracker#{t.id}".to_sym, {:issues => :index}
    end
  end
end

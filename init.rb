require 'redmine'
require 'redmine_track_control/tracker_helper'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'tracker'
  Tracker.send(:include, RedmineTrackControl::TrackerPatch)

  require_dependency 'issue'
  Issue.send(:include, RedmineTrackControl::IssuePatch)

  require_dependency 'roles_controller'
  RolesController.send(:include, RedmineTrackControl::RolesControllerPatch)

  require_dependency 'issues_controller'
  IssuesController.send(:include, RedmineTrackControl::IssuesControllerPatch)
  
  require_dependency 'issue_query'
  IssueQuery.send(:include, RedmineTrackControl::IssueQueryPatch)
end

Redmine::Plugin.register :redmine_track_control do
  name 'Redmine Tracker Control plugin'
  author 'Jijesh Mohan'
  description 'Plugin for controlling tracker wise issue creation'
  version '1.1.0'
  url 'https://github.com/jijeshmohan/redmine_track_control'
  author_url 'jijeshmohan.wordpress.com'

  project_module :tracker_permissions do
    Tracker.all.each do |t|
      RedmineTrackControl::TrackerHelper.add_tracker_permission(t)
    end
  end
end

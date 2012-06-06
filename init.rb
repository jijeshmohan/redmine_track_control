require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'tracker'
  Tracker.send(:include, TrackerPatch) unless Issue.included_modules.include? TrackerPatch

  require_dependency 'role'
  Role.send(:include, RolePatch)

  require_dependency 'issue'
  Issue.send(:include, IssuePatch) unless  Issue.included_modules.include? IssuePatch

  require_dependency 'issues_helper'
  IssuesHelper.send(:include,IssueHelperPatch)
end

Redmine::Plugin.register :redmine_track_control do
  name 'Redmine Tracker Control plugin'
  author 'Jijesh Mohan'
  description 'Plugin for controlling tracker wise issue creation'
  version '1.0.5'
  url 'https://github.com/jijeshmohan/redmine_track_control'
  author_url 'jijeshmohan.wordpress.com'

  project_module :tracker_permissions do
    Tracker.all.each do |t|
      permission "create_#{t.name}_tracker".to_sym, {:issues => :index}
    end
  end
end

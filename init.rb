require 'redmine'

require 'dispatcher'

Dispatcher.to_prepare :redmine_track_control do
  require_dependency 'tracker'
  Tracker.send(:include, TrackerPatch) unless Issue.included_modules.include? TrackerPatch
end

Redmine::Plugin.register :redmine_track_control do
  name 'Redmine Tracker Control plugin'
  author 'Jijesh Mohan'
  description 'Plugin for controlling tracker wise issue creation'
  version '1.0.0'
  url 'https://github.com/jijeshmohan/redmine_track_control'
  author_url ''

  project_module :tracker_permissions do
    Tracker.all.each do |t|
      permission "create_#{t.name}_tracker".to_sym, {:issues => :index}
    end
  end
end

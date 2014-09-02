require 'redmine_track_control/tracker_helper'

module TrackControlHelper
  def valid_trackers_list(project)
     if project.enabled_modules.where(:name => "tracker_permissions").count == 1     #Change for check tracker permission module is enable
        project.trackers.select{|t| User.current.allowed_to?("create_tracker#{t.id}".to_sym, project, :global => true)}.collect {|t| [t.name, t.id]}
     else
        project.trackers.collect {|t| [t.name, t.id]}
     end
  end

  def display_tracker_select(project,issue,f)
    tracker_list=valid_trackers_list(project)
    if project.enabled_modules.where(:name => "tracker_permissions").count == 1
      unless issue.new_record?
        current_tracker = [issue.tracker.name,issue.tracker.id]
        tracker_list << current_tracker unless tracker_list.include? current_tracker
      end
    end
    f.select :tracker_id, tracker_list, {:required => true},
             :onchange => "updateIssueFrom('#{escape_javascript project_issue_form_path(project, :id => issue, :format => 'js')}')"
  end
end

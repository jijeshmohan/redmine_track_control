require 'redmine_track_control/tracker_helper'

module TrackControlHelper
  def valid_trackers_list(project)
    RedmineTrackControl::TrackerHelper.valid_trackers_list(project)
  end

  def display_tracker_select(project,issue,f)
    tracker_list = RedmineTrackControl::TrackerHelper.valid_trackers_list(project)
    if project.enabled_modules.where(:name => "tracker_permissions").count == 1
      unless issue.new_record?
        current_tracker = [issue.tracker.name,issue.tracker.id]
        tracker_list << current_tracker unless tracker_list.include? current_tracker
      end
    end
    f.select :tracker_id, tracker_list, {:required => true},
             :onchange => "updateIssueFrom('#{escape_javascript update_issue_form_path(project, issue)}')"
  end
end

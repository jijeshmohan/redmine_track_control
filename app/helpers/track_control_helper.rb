module TrackControlHelper
  def valid_trackers_list(project)
    project.trackers.select{|t| User.current.allowed_to?("create_tracker#{t.id}".to_sym, project, :global => true)}.collect {|t| [t.name, t.id]}
  end

  def display_tracker_select(project,issue,f)
    if project.enabled_modules.where(:name => "tracker_permissions").count == 1
      tracker_list=valid_trackers_list(project)
      unless issue.new_record?
        current_tracker = [issue.tracker.name,issue.tracker.id]
        tracker_list << current_tracker unless tracker_list.include? current_tracker
      end
    else
      tracker_list = project.trackers.collect {|t| [t.name, t.id]}
    end
    f.select :tracker_id, tracker_list, :required => true,
             :onchange => "updateIssueFrom('#{escape_javascript project_issue_form_path(project, :id => issue, :format => 'js')}')"
  end
end

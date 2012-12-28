module  IssueHelperPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def display_tracker_select(project,issue,f)
     tracker_list=project.trackers.select{|t| User.current.allowed_to?("create_#{t.name.downcase.gsub(/\ +/,'_')}_tracker".to_sym, project, :global => true)}.collect {|t| [t.name, t.id]}
      unless issue.new_record?
        current_tracker = [issue.tracker.name,issue.tracker.id]
        tracker_list << current_tracker unless current_tracker.include? current_tracker
      end
       f.select :tracker_id, tracker_list, {:required => true},
                :onchange => "updateIssueFrom('#{escape_javascript project_issue_form_path(project, :id => issue, :format => 'js')}')"
    end
  end
end


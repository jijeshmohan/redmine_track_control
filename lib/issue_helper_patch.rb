module  IssueHelperPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def display_tracker_select(project,issue,f)
       tracker_list = project.trackers.reject{|t| User.current.allowed_to?("create_#{t.name}_tracker".to_sym, project, :global => true).nil?}.collect {|t| [t.name, t.id]}
      unless issue.new_record?
        current_tracker = [issue.tracker.name,issue.tracker.id]
        tracker_list << current_tracker unless current_tracker.include? current_tracker
      end
      f.select :tracker_id, tracker_list, :required => true
    end
  end
end


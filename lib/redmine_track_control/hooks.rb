module RedmineTrackControl
  class Hooks < Redmine::Hook::ViewListener

    include IssuesControllerPatch::InstanceMethods

    # rewrite select for trackers on issue form
    def view_issues_form_details_top(context={})
      @issue = context[:issue]
      @project = context[:project]
      tracker_ids = allowed_tracker_ids_with_trackcontrol
      @allowed_trackers = Tracker.where(:id => tracker_ids).order("#{Tracker.table_name}.position")

      "<script type='text/javascript'>
        $('select#issue_tracker_id').ready(function() {
          $('select#issue_tracker_id').html('#{escape_javascript(options_for_select(@allowed_trackers.collect { |t| [t.name, t.id] }, @issue.tracker_id))}');
        })
      </script>"
    end

  end

end

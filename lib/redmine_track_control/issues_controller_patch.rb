require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  module IssuesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        helper 'track_control'

        alias_method_chain :build_new_issue_from_params, :tracker_control
        alias_method_chain :update_issue_from_params, :tracker_control
      end
    end

    module InstanceMethods
      def build_new_issue_from_params_with_tracker_control
        build_new_issue_from_params_without_tracker_control
        return true if @issue.project.enabled_modules.where(:name => "tracker_permissions").count == 0
        return true if User.current.admin?
        if RedmineTrackControl::TrackerHelper.valid_trackers_list(@issue.project).empty?  
          render_error l(:error_no_tracker_in_project)
          return false
        end
      end

      def update_issue_from_params_with_tracker_control
        old_tracker_id = @issue.tracker.id
        update_issue_from_params_without_tracker_control
        return true if (@issue.project.enabled_modules.where(:name => "tracker_permissions").count == 0) or (params[:tracker_id].blank?) or (old_tracker_id == params[:tracker_id])
        return true if User.current.admin?
        if RedmineTrackControl::TrackerHelper.valid_trackers_list(@issue.project).empty?  
          render_error l(:error_no_tracker_in_project)
          return false
        end
      end
    end
  end
end

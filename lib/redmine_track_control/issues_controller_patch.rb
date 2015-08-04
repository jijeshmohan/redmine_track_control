require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  module IssuesControllerPatch

    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        before_filter :check_tracker_id_with_trackcontrol, :only => [:new, :create, :update]
        alias_method_chain :build_new_issue_from_params, :trackcontrol
        alias_method_chain :update_issue_from_params, :trackcontrol

      end
    end

    module InstanceMethods

      # nullify tracker_id if it is not allowed
      def check_tracker_id_with_trackcontrol
        tracker_ids = allowed_tracker_ids_with_trackcontrol
        if @issue.tracker_id_changed? && tracker_ids.exclude?(@issue.tracker_id)
          @issue.tracker_id = nil
        end
      end

      # build possible trackers for issue.
      # Possible trackers for user are:
      # predefined trackers by admin in "Roles and Permissions" + current issue's tracker (it allows user update issue and leave current tracker)
      def allowed_tracker_ids_with_trackcontrol
        # join trackers from permissions
        tracker_ids = get_tracker_ids

        # add current issue's tracker if issue exists and tracker_ids contains smth
        tracker_ids << @issue.tracker_id_was if @issue && @issue.persisted? && tracker_ids.any?
        tracker_ids
      end

      # default params[:tracker_id] is taken from project settings @project.trackers.first
      # fields (defined by permissions) to display on the form are based on this value
      # predefine params[:tracker_id] with value according plugin settings
      def build_new_issue_from_params_with_trackcontrol
        params[:tracker_id] ||= get_tracker_ids.first
        build_new_issue_from_params_without_trackcontrol
      end
      
      def update_issue_from_params_with_trackcontrol
        params[:tracker_id] ||= get_tracker_ids.first
        update_issue_from_params_without_trackcontrol
      end      

      private
      
      # join trackers from permissions
      def get_tracker_ids(permtype="create")
        @tracker_ids = RedmineTrackControl::TrackerHelper.valid_trackers_ids(@project,permtype)
        @tracker_ids.flatten.uniq
      end      

    end
  end
end

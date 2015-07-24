require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  
  module IssueQueryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        alias_method_chain :available_filters, :trackcontrol
      end
    end

    module InstanceMethods
      def available_filters_with_trackcontrol
        @available_filters = available_filters_without_trackcontrol
        if not project.nil?
          delete_available_filter "tracker_id"
          add_available_filter "tracker_id", :type => :list, :name => "Tracker", :values => RedmineTrackControl::TrackerHelper.valid_trackers_list(self.project)
        end
        @available_filters
      end
    end
  end
end

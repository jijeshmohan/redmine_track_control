require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  
  module QueryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        alias_method_chain :trackers, :trackcontrol
      end
    end

    module InstanceMethods
      def trackers_with_trackcontrol       
        @trackers ||= Tracker.where(:id => RedmineTrackControl::TrackerHelper.valid_trackers_ids(project,"show")).order("#{Tracker.table_name}.position")
      end
    end
  end
end

require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  module  IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
            unloadable
            validate :is_valid_tracker, :on => :create
      end
    end

    module InstanceMethods
      private
        def is_valid_tracker
          errors.add(:tracker_id, :invalid) if RedmineTrackControl::TrackerHelper.valid_trackers_list(self.project).empty?
        end
    end
  end
end

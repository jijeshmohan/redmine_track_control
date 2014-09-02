require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  module  IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
            unloadable
            validate :is_tracker_valid, :on => :create
      end
    end

    module InstanceMethods
      private
         def valid_trackers_list(project)  #Added for check whether user having a valid tracker for the project
          if project.enabled_modules.where(:name => "tracker_permissions").count == 1
            project.trackers.select{|t| User.current.allowed_to?("create_tracker#{t.id}".to_sym, project, :global => true)}.collect {|t| [t.name, t.id]}
          else
            project.trackers.collect {|t| [t.name, t.id]}
          end
        end

        def is_valid_tracker
          tracker_permission_flag = "create_tracker#{self.tracker.id}".to_sym
          errors.add(:tracker_id, :invalid) if valid_trackers_list(self.project).empty?
        end
    end
  end
end

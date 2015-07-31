require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  
  module VersionsControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        alias_method_chain :index, :trackcontrol
      end
    end

    module InstanceMethods
      def index_with_trackcontrol
        index_without_trackcontrol
        respond_to do |format|
          format.html {        
            projects = @with_subprojects ? @project.self_and_descendants : [@project]
            @trackers = []
            projects.each do |prj|
              @trackers |= Tracker.where(:id => RedmineTrackControl::TrackerHelper.valid_trackers_ids(prj, "show")).order("#{Tracker.table_name}.position")              
            end             
            @trackers = @trackers.compact.reject(&:blank?).uniq.sort
            retrieve_selected_tracker_ids(@trackers, @trackers.select {|t| t.is_in_roadmap?})                     
          }
        end    
      end
    end
  end
end

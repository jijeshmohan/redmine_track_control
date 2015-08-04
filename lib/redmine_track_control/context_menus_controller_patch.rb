require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  
  module ContextMenusControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        alias_method_chain :issues, :trackcontrol
      end
    end

    module InstanceMethods
      def issues_with_trackcontrol       
        if (@issues.size == 1)
          @issue = @issues.first
        end
        @issue_ids = @issues.map(&:id).sort

        @allowed_statuses = @issues.map(&:new_statuses_allowed_to).reduce(:&)

        @can = {:edit => User.current.allowed_to?(:edit_issues, @projects),
          :log_time => (@project && User.current.allowed_to?(:log_time, @project)),
          :update => (User.current.allowed_to?(:edit_issues, @projects) || (User.current.allowed_to?(:change_status, @projects) && !@allowed_statuses.blank?)),
          :move => (@project && User.current.allowed_to?(:move_issues, @project)),
          :copy => (@issue && @project.trackers.include?(@issue.tracker) && User.current.allowed_to?(:add_issues, @project)),
          :delete => User.current.allowed_to?(:delete_issues, @projects)
        }
        if @project
          if @issue
            @assignables = @issue.assignable_users
          else
            @assignables = @project.assignable_users
          end
          @trackers = Tracker.where(:id => RedmineTrackControl::TrackerHelper.valid_trackers_ids(@project, "create")).order("#{Tracker.table_name}.position") 
          if @issue
            @trackers << @issue.tracker
          end
          @trackers = @trackers.compact.reject(&:blank?).uniq.sort
        else
          #when multiple projects, we only keep the intersection of each set
          @assignables = @projects.map(&:assignable_users).reduce(:&)
          @trackers = @projects.map(&:trackers).reduce(:&)
          @projects.each do |prj|
            @trackers = @trackers & Tracker.where(:id => RedmineTrackControl::TrackerHelper.valid_trackers_ids(prj, "create")).order("#{Tracker.table_name}.position")              
          end             
          @trackers = @trackers.compact.reject(&:blank?).uniq.sort
        end
        @versions = @projects.map {|p| p.shared_versions.open}.reduce(:&)

        @priorities = IssuePriority.active.reverse
        @back = back_url

        @options_by_custom_field = {}
        if @can[:edit]
          custom_fields = @issues.map(&:editable_custom_fields).reduce(:&).reject(&:multiple?)
          custom_fields.each do |field|
            values = field.possible_values_options(@projects)
            if values.present?
              @options_by_custom_field[field] = values
            end
          end
        end

        @safe_attributes = @issues.map(&:safe_attribute_names).reduce(:&)
        render :layout => false
      end      
    end
  end
end

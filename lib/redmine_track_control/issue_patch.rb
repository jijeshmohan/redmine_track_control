require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  module  IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)      
      base.class_eval do
        unloadable
        validate :is_valid_create_tracker, :on => :create
        validate :is_valid_show_tracker, :on => :show
        alias_method_chain :visible?, :trackcontrol             
        
        # ========= start patch visible_condition =========
        unless Issue.respond_to?(:visible_condition_block)
          # move logic for patching logic in separate method in order to avoid possible conflicts with another plugins        
          
          # Returns a SQL conditions string used to find all issues visible by the specified user on it's index page
          def self.visible_condition(user, options={})
            Project.allowed_to_condition(user, :view_issues, options) do |role, user|
              visible_condition_block(role, user)                            
            end
          end
          
          # this is origin logic which is moved in separate method for patching purposes
          def self.visible_condition_block(role, user)
            if user.logged?
              case role.issues_visibility
              when 'all'
                nil
              when 'default'
                user_ids = [user.id] + user.groups.map(&:id)
                "(#{table_name}.is_private = #{connection.quoted_false} OR #{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
              when 'own'
                user_ids = [user.id] + user.groups.map(&:id)
                "(#{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
              else
                '1=0'
              end
            else
              "(#{table_name}.is_private = #{connection.quoted_false})"
            end
          end
        end

        # patch for visible_condition_block
        def self.visible_condition_block_with_trackcontrol(role, user)          
          if user.logged?
            # prepend extra access condition
            condition = [extra_access_conditions(role)]
            if !condition.empty?
              condition << owner_conditions(user)
              condition.delete_if(&:blank?).join (' OR ')
            else
              visible_condition_block_without_trackcontrol(role, user)
            end
          else
            visible_condition_block_without_trackcontrol(role, user)
          end
        end
        
        class << self
          # use alias_method_chain to have origin methods and patched ones.
          # it will help to patch origin logic in other places (=plugins)
          alias_method_chain :visible_condition_block, :trackcontrol
        end        

        # ========= end patch visible_condition =========
        
        private
        # user should see issues if he is author or it is assigned to him
        def self.owner_conditions(user)
          user_ids = [user.id] + user.groups.map(&:id)
          "(#{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
        end

        # user should see issues if he has an extra access
        def self.extra_access_conditions(role)
          tracker_ids = RedmineTrackControl::TrackerHelper.trackers_ids_by_role(role,"show")
          if (!tracker_ids.empty?)
            "((#{table_name}.tracker_id IN (#{tracker_ids.join(',')})) OR #{table_name}.project_id NOT IN (SELECT em.project_id FROM #{EnabledModule.table_name} em WHERE em.name='tracker_permissions'))"
          end
        end
        
      end
    end     
       

    module InstanceMethods
      def visible_with_trackcontrol?(usr=nil)        
        visible_without_trackcontrol?(usr) && (RedmineTrackControl::TrackerHelper.issue_has_valid_tracker?(self,"show", usr) || (usr || User.current).admin?)
      end
          
  
      private
      def is_valid_create_tracker
        errors.add(:tracker_id, :invalid) if RedmineTrackControl::TrackerHelper.valid_trackers_list(self.project,"create").empty?
      end
      
      def is_valid_show_tracker
        errors.add(:tracker_id, :invalid) if RedmineTrackControl::TrackerHelper.valid_trackers_list(self.project,"show").empty?
      end    end
  end
end

#Patches Redmine's RolesController.
require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  module RolesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        unloadable
        before_filter :store_translations
      end
    end

    module InstanceMethods
      def store_translations
        Tracker.all.each do |t|
          permission_key = ("permission_" + RedmineTrackControl::TrackerHelper.permission(t).to_s).to_sym
          I18n.backend.store_translations(:en, { permission_key => l(:trackcontrol_create_tracker, t.name) })
        end
      end
    end
  end
end

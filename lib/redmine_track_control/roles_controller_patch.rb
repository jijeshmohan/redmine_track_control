#Patches Redmine's RolesController.
module RedmineTrackControl
  module RolesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        alias_method_chain :show, :tracker_translations
        alias_method_chain :permissions, :tracker_translations
      end
    end

    module InstanceMethods
      def show_with_tracker_translations
        Tracker.all.each do |t|
          I18n.backend.store_translations(:en, { "permission_create_tracker#{t.id}".to_sym => l(:trackcontrol_create_tracker, t.name) })
        end
        show_without_tracker_translations
      end

      def permissions_with_tracker_translations
        Tracker.all.each do |t|
          I18n.backend.store_translations(:en, { "permission_create_tracker#{t.id}".to_sym => l(:trackcontrol_create_tracker, t.name) })
        end
        permissions_without_tracker_translations
      end
    end
  end
end

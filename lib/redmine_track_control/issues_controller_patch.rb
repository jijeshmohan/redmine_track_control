module RedmineTrackControl
  module IssuesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        helper 'track_control'

        alias_method_chain :build_new_issue_from_params, :tracker_control
        alias_method_chain :update_issue_from_params, :tracker_control
      end
    end

    module InstanceMethods
      def build_new_issue_from_params_with_tracker_control
        build_new_issue_from_params_without_tracker_control
        return false if !User.current.allowed_to?("create_tracker#{@issue.tracker.id}".to_sym, @issue.project, :global => true)
      end

      def update_issue_from_params_with_tracker_control
        update_issue_from_params_without_tracker_control
        return false if !User.current.allowed_to?("create_tracker#{@issue.tracker.id}".to_sym, @issue.project, :global => true)
      end
    end
  end
end

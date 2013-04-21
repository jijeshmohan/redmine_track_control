module RedmineTrackControl
  module IssuesControllerPatch
    def self.perform
      IssuesController.class_eval do
        helper 'track_control'
      end
    end
  end
end

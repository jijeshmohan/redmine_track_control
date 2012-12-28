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
        tracker_name = "create_#{self.tracker.name.downcase.gsub(/\ +/,'_')}_tracker".to_sym
        errors.add(:tracker_id,"not allowed") if User.current.allowed_to?(tracker_name, self.project, :global => true).nil?
      end
  end
end

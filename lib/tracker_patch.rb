#Patches Redmine's Tracker. Adds callback to manipulate permission
module  TrackerPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    # Same as typing in the class
    base.class_eval do
      unloadable
      after_create :add_tracker_permission, :on => :create
      after_destroy :remove_tracker_permission
    end
  end

  module ClassMethods

  end

  module InstanceMethods
    private
    def add_tracker_permission
      Redmine::AccessControl.map {|map| map.project_module(:tracker_permissions) {|map|map.permission("create_#{name.downcase.gsub(/\ +/,'_')}_tracker".to_sym, {:issues => :index}, {})}}
    end
    def remove_tracker_permission
      perm = Redmine::AccessControl.permission("create_#{name.downcase.gsub(/\ +/,'_')}_tracker".to_sym)
      Redmine::AccessControl.permissions.delete perm unless perm.nil?
    end
  end

end

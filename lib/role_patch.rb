#Patches Redmine's Role.
module RolePatch
  def self.included(base)
    base.class_eval do
      unloadable
      alias_method :permissions_without_unicode, :permissions unless method_defined? :permissions_without_unicode

      def permissions
        read_attribute(:permissions) || []
        return self[:permissions] unless self[:permissions]
        self[:permissions].map! do |p|
          if p.instance_of? String
            p.split('').slice(1..-1).join.to_sym
          else
            p
          end
        end
      end
    end
  end
end
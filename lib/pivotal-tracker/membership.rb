module PivotalTracker
  class Membership
    include HappyMapper

    class << self
      def all(project, options={})
        parse(Client.connection["/projects/#{project.id}/memberships"].get)
      end
    end

    element :id, Integer
    element :role, String

    # Flattened Attributes from <person>...</person>
    element :name, String, :deep => true
    element :email, String, :deep => true
    element :initials, String, :deep => true

    def initialize(attributes={})
      update_attributes(attributes)
    end

    def assign(project, options={})
      puts self.to_xml
      response = Client.connection["/projects/#{project.id}/memberships/"].post(self.to_xml, :content_type => 'application/xml')
      membership = Membership.parse(response)
      return membership
    end

    protected

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.membership {
            xml.role "#{role}"
            xml.person {
              xml.name "#{name}"
              xml.email "#{email}"
              xml.initials "#{initials}" unless initials.nil?
            }
          }
        end
        return builder.to_xml
      end

      def update_attributes(attrs)
        attrs.each do |key, value|
          self.send("#{key}=", value.is_a?(Array) ? value.join(',') : value )
        end
      end
  end
end

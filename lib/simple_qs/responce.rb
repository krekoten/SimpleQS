require 'xmlsimple'

require 'simple_qs/responce/exceptions'

module SimpleQS
  class Responce
    
    autoload :SuccessfulBuilder,    'simple_qs/responce/successful_builder'
    autoload :FailureBuilder,       'simple_qs/responce/failure_builder'
    
    def initialize(xml)
      _parse xml
    end
    
    def successful?
      !@xml_data.key?('ErrorResponse')
    end

    def root_element
      @xml_data.keys[0]
    end
    
    private
    
    def _parse(xml)
      @xml_data = XmlSimple.xml_in(xml, {'ForceArray' => false, 'KeepRoot' => true})
      (successful? ? SuccessfulBuilder : FailureBuilder).build(self)
    end
  end
end

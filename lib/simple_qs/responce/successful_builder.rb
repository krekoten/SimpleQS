module SimpleQS
	class Responce
		class SuccessfulBuilder
			def self.build responce
				responce.instance_eval do

					def action_name
						@action_name ||= root_element.gsub(/Response/, '')
					end

					def request_id
						@xml_data[root_element]['ResponseMetadata']['RequestId']
					end

					@xml_data[root_element]["#{action_name}Result"].each do |key, value|
						self.instance_eval %{
							def #{key.gsub(/([A-Z]+)/, '_\1').downcase.gsub(/^_/, '')}
								#{value.inspect}
							end
						}
					end if @xml_data[root_element]["#{action_name}Result"]
				end
			end
		end
	end
end

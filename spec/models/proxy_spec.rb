require 'spec_helper'

describe Proxy do
	it 'should fetch proxy' do
		proxy = Proxy.new(endpoint: 'http://www.machu.jp/amazon_proxy/')
		res = proxy.fetch('jp', 'test=aaa')
		res.code.should == '302'
		res['location'].should be_true
	end
end

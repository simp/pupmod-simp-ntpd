require 'spec_helper'

describe 'ntpd::allow' do
  let(:title){ 'test' }

  it { should compile.with_all_deps }
  it { should create_concat_fragment("ntpd+#{title}.allow").with_content(<<-EOF.gsub(/^\s+/,'')
    restrict 1.2.3.0 mask 255.255.255.0
    restrict 3.4.5.6
    EOF
  )}
end

require 'spec_helper'

describe 'ntpd::allow' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }
        let(:title){ 'test' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_simpcat_fragment("ntpd+#{title}.allow").with_content(<<-EOF.gsub(/^\s+/,'')
          restrict 1.2.3.0 mask 255.255.255.0
          restrict 3.4.5.6
          EOF
        )}
      end
    end
  end
end

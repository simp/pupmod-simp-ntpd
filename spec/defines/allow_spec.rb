require 'spec_helper'

describe 'ntpd::allow' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }
        let(:title){ 'test' }

        context 'with default parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat__fragment("ntpd_#{title}.allow").with_content(<<-EOF.gsub(/^\s+/,'')
            restrict 1.2.3.0 mask 255.255.255.0
            restrict 3.4.5.6
            EOF
          )}
          it { is_expected.to_not contain_class('iptables')}
          it { is_expected.to_not contain_iptables__listen__udp('allow_ntp_test')}
        end

        context 'with firewall => true' do
          let(:params) {{:firewall => true}}
          it { is_expected.to contain_class('iptables')}
          it { is_expected.to contain_iptables__listen__udp('allow_ntp_test')}
        end
      end
    end
  end
end

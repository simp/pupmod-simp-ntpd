require 'spec_helper'

describe 'ntpd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with default parmeters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat('/etc/ntp.conf') }
          it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(/fudge\s+127\.127\.1\.0\s+stratum 2/) }
          it { is_expected.to_not contain_class('auditd')}
        end

        context 'virtual' do
          let(:facts){{ :virtual => 'kvm' }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(/tinker panic 0/) }
        end

        context 'with auditd => true' do
          let(:params){{ :auditd => true }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('auditd') }
          it { is_expected.to create_auditd__add_rules('ntp') }
        end

        context 'with_servers_hash' do
          let(:params){{
            'servers' => {
              'time.bar.baz' => ['prefer'],
              'time.other.net' => []
            }
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(/fudge\s+127\.127\.1\.0\s+stratum 10/) }
        end
      end
    end
  end
end

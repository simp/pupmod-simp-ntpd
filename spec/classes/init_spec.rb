require 'spec_helper'

describe 'ntpd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat_build('ntpd') }
        it { is_expected.to create_concat_fragment('ntpd+ntp.conf').with_content(/fudge\s+127\.127\.1\.0\s+stratum 2/) }

        context 'virtual' do
          let(:facts){{ :virtual => 'kvm' }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat_fragment('ntpd+ntp.conf').with_content(/tinker panic 0/) }
        end

        context 'with_auditd' do
          let(:params){{ :use_auditd => true }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('auditd') }
          it { is_expected.to create_auditd__add_rules('ntp') }
        end

        context 'with_servers_hash' do
          let(:params){{
            :servers => {
              'time.bar.baz' => ['prefer'],
              'time.other.net' => []
            }
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat_fragment('ntpd+ntp.conf').with_content(/fudge\s+127\.127\.1\.0\s+stratum 10/) }
        end
      end
    end
  end
end

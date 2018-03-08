require 'spec_helper'

describe 'ntpd' do
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
        it { is_expected.to create_file('/etc/sysconfig/ntpd').with_content(<<-EOF.gsub(/^\s+/,'')
            OPTIONS="-A -u ntp:ntp -p /var/run/ntpd.pid"
          EOF
        ) }
        it { is_expected.to create_file('/etc/sysconfig/ntpdate').with_content(<<-EOF.gsub(/^\s+/,'')
            SYNC_HWCLOCK=yes
          EOF
        ) }
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
        it { is_expected.to create_auditd__rule('ntp').with_content(<<-EOF.gsub(/^\s+/,'')
            -w /etc/ntp.conf -p wa -k CFG_ntp
            -w /etc/ntp/keys -p wa -k CFG_ntp
          EOF
        ) }
      end

      context 'with servers array' do
        let(:params){{
          'servers' => [
            'time.bar.baz',
            'time.other.net'
          ]
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(/fudge\s+127\.127\.1\.0\s+stratum 10/) }
        it { is_expected.to create_file('/etc/ntp/step-tickers').with_content(<<-EOF.gsub(/^\s+/,'')
            # List of NTP servers used by the ntpdate service.
            # This file is managed by Puppet (module: ntp)
            time.bar.baz
            time.other.net
          EOF
        ) }
      end

      context 'with servers hash' do
        let(:params){{
          'servers' => {
            'time.bar.baz' => ['prefer'],
            'time.other.net' => []
          }
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(/fudge\s+127\.127\.1\.0\s+stratum 10/) }
        it { is_expected.to create_file('/etc/ntp/step-tickers').with_content(<<-EOF.gsub(/^\s+/,'')
            # List of NTP servers used by the ntpdate service.
            # This file is managed by Puppet (module: ntp)
            time.bar.baz
            time.other.net
          EOF
        ) }
      end
    end
  end
end

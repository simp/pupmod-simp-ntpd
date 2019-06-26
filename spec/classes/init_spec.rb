require 'spec_helper'

describe 'ntpd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'with default parmeters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat('/etc/ntp.conf') }
        it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(<<-EOF.gsub(/^[ ]+/,'')
            logconfig =syncall +clockall

            tinker panic 0

            restrict default kod nomodify notrap nopeer noquery
            restrict -6 default kod nomodify notrap nopeer noquery

            restrict 127.0.0.1
            restrict -6 ::1

            server 127.127.1.0 # local clock
            fudge 127.127.1.0 stratum 2


            driftfile /var/lib/ntp/drift
            broadcastdelay 0.004
            disable monitor
            EOF
        ) }

        it { is_expected.to_not contain_class('auditd')}
        it { is_expected.to_not contain_ntpd__allow('simp_default_ntpd_allow') }
        if os =~ /7/
          it { is_expected.to create_file('/etc/sysconfig/ntpd').with_content(%r{OPTIONS="-g"}) }
          it { is_expected.to create_file('/etc/sysconfig/ntpdate').with_content(<<-EOF.gsub(/^\s+/,'')
            # Configuration for the ntpdate script that runs at boot
            # This file is managed by Puppet (module: ntpd)
            # Options for ntpdate
            OPTIONS="-p 2"
            # Number of retries before giving up
            RETRY=2
            # Set to 'yes' to sync hw clock after successful ntpdate
            SYNC_HWCLOCK=yes
            EOF
          ) }
        else
          it { is_expected.to create_file('/etc/sysconfig/ntpd').with_content(%r{OPTIONS="-A -u ntp:ntp -p /var/run/ntpd.pid"}) }
          it { is_expected.to create_file('/etc/sysconfig/ntpdate').with_content(<<-EOF.gsub(/^\s+/,'')
            # Configuration for the ntpdate script that runs at boot
            # This file is managed by Puppet (module: ntpd)
            # Options for ntpdate
            OPTIONS="-U ntp -s -b"
            # Number of retries before giving up
            RETRY=2
            # Set to 'yes' to sync hw clock after successful ntpdate
            SYNC_HWCLOCK=yes
            EOF
          ) }
        end
      end

      context 'virtual' do
        let(:facts) {
          os_facts.merge({:virtual => 'kvm'})
        }

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
        it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(<<-EOF.gsub(/^[ ]+/,'')
            logconfig =syncall +clockall

            tinker panic 0

            restrict default kod nomodify notrap nopeer noquery
            restrict -6 default kod nomodify notrap nopeer noquery

            restrict 127.0.0.1
            restrict -6 ::1

            server 127.127.1.0 # local clock
            fudge 127.127.1.0 stratum 10

            server time.bar.baz minpoll 4 maxpoll 4 iburst
            server time.other.net minpoll 4 maxpoll 4 iburst
            driftfile /var/lib/ntp/drift
            broadcastdelay 0.004
            disable monitor
            EOF
        ) }

        it { is_expected.to create_file('/etc/ntp/step-tickers').with_content(<<-EOF.gsub(/^\s+/,'')
            # List of NTP servers used by the ntpdate service.
            # This file is managed by Puppet (module: ntpd)
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
          },
          'discard' => {
            'average' => 3,
            'minimum' => 0,
          }
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(<<-EOF.gsub(/^[ ]+/,'')
            logconfig =syncall +clockall

            tinker panic 0

            discard average 3 minimum 0
            restrict default kod nomodify notrap nopeer noquery
            restrict -6 default kod nomodify notrap nopeer noquery

            restrict 127.0.0.1
            restrict -6 ::1

            server 127.127.1.0 # local clock
            fudge 127.127.1.0 stratum 10

            server time.bar.baz prefer
            server time.other.net minpoll 4 maxpoll 4 iburst
            driftfile /var/lib/ntp/drift
            broadcastdelay 0.004
            disable monitor
            EOF
        ) }

        it { is_expected.to create_file('/etc/ntp/step-tickers').with_content(<<-EOF.gsub(/^\s+/,'')
            # List of NTP servers used by the ntpdate service.
            # This file is managed by Puppet (module: ntpd)
            time.bar.baz
            time.other.net
          EOF
        ) }
      end

      context 'with extra content' do
        let(:params){{
          'extra_content' => "This is some\nextra content"
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(<<-EOF.gsub(/^[ ]+/,'')
            logconfig =syncall +clockall

            tinker panic 0

            restrict default kod nomodify notrap nopeer noquery
            restrict -6 default kod nomodify notrap nopeer noquery

            restrict 127.0.0.1
            restrict -6 ::1

            server 127.127.1.0 # local clock
            fudge 127.127.1.0 stratum 2


            driftfile /var/lib/ntp/drift
            broadcastdelay 0.004
            disable monitor

            # Begin raw user content
            This is some
            extra content
            # End raw user content
            EOF
        ) }
      end

      context 'with fully user-defined content' do
        let(:params){{
          'config_content' => 'This is all you get',
          'extra_content' => "This is some\nextra content"
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat__fragment('main_ntp_configuration').with_content(<<-EOF.gsub(/^[ ]+/,'')
            # Begin user-defined configuration
            This is all you get
            # End user-defined configuration
            EOF
        ) }
      end

      context 'with servers and vmware' do
        let(:facts) {
          os_facts.merge({:virtual => 'vmware'})
        }

        let(:params){{
          'servers' => [
            'time.bar.baz',
            'time.other.net'
          ]
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to_not create_concat__fragment('main_ntp_configuration').with_content(/server\s+127\.127\.1\.0/) }
        it { is_expected.to_not create_concat__fragment('main_ntp_configuration').with_content(/fudge\s+127\.127\.1\.0\s+stratum/) }
      end

      context 'with logconfig empty' do
        let(:params){{ :logconfig => [] }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to_not create_concat__fragment('main_ntp_configuration').with_content(/logconfig/) }
      end

      context 'when allowing remote connections' do
        context 'with just trusted_nets defined' do
          let(:params){{
            :trusted_nets => ['127.0.0.1', 'localhost']
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_ntpd__allow('simp_default_ntpd_allow').with_rules(nil) }
          it { is_expected.to create_ntpd__allow('simp_default_ntpd_allow').with_trusted_nets(params[:trusted_nets]) }
        end

        context 'with rules defined' do
          let(:params){{
            :trusted_nets => ['127.0.0.1', 'localhost'],
            :default_restrict_rules => ['kod']
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_ntpd__allow('simp_default_ntpd_allow').with_rules(params[:default_restrict_rules]) }
          it { is_expected.to create_ntpd__allow('simp_default_ntpd_allow').with_trusted_nets(params[:trusted_nets]) }
        end
      end
    end
  end
end

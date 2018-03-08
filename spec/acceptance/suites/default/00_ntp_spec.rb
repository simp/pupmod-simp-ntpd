require 'spec_helper_acceptance'
require 'json'

test_name 'prepare system for kubeadm'

describe 'prepare system for kubeadm' do
  let(:hiera) {{
    'simp_options::ntpd::servers' => [
      '0.rhel.pool.ntp.org',
      '1.rhel.pool.ntp.org',
      '2.rhel.pool.ntp.org',
      '3.rhel.pool.ntp.org',
    ]
  }}
  let(:manifest) {
    "include 'ntpd'"
  }

  context 'on each host' do
    hosts.each do |host|
      it 'should work with default values' do
        set_hieradata_on(host, hiera)
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      describe file('/etc/ntp.conf') do
        ntp_conf = File.read('spec/acceptance/suites/default/expected/ntp.conf.txt')

        it { should be_file }
        its(:content) { should match(ntp_conf) }
      end

      describe file('/etc/ntp/step-tickers') do
        step_tickers = <<-EOF.gsub(/^\s+/,'')
          # List of NTP servers used by the ntpdate service.
          # This file is managed by Puppet (module: ntp)
          0.rhel.pool.ntp.org
          1.rhel.pool.ntp.org
          2.rhel.pool.ntp.org
          3.rhel.pool.ntp.org
        EOF

        it { should be_file }
        its(:content) { should match(step_tickers) }
      end

      describe file('/etc/sysconfig/ntpd') do
        it { should be_file }
        its(:content) { should match(%r{OPTIONS="-A -u ntp:ntp -p /var/run/ntpd.pid"}) }
      end

      describe file('/etc/sysconfig/ntpdate') do
        it { should be_file }
        its(:content) { should match(/SYNC_HWCLOCK=yes/) }
      end
    end
  end
end

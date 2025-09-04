# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'json'

test_name 'ntp'

describe 'ntpd' do
  let(:hiera) do
    {
      'simp_options::ntpd::servers' => [
        '0.rhel.pool.ntp.org',
        '1.rhel.pool.ntp.org',
        '2.rhel.pool.ntp.org',
        '3.rhel.pool.ntp.org',
      ],
    }
  end
  let(:manifest) do
    "include 'ntpd'"
  end

  hosts.each do |host|
    context "on #{host}" do
      it 'works with default values' do
        set_hieradata_on(host, hiera)
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      describe file('/etc/ntp.conf') do
        ntp_conf = File.read('spec/acceptance/suites/default/expected/ntp.conf.txt')

        it { is_expected.to be_file }
        its(:content) { is_expected.to match(ntp_conf) }
      end

      describe file('/etc/ntp/step-tickers') do
        step_tickers = <<~STEP_TICKERS
          # List of NTP servers used by the ntpdate service.
          # This file is managed by Puppet (module: ntpd)
          0.rhel.pool.ntp.org
          1.rhel.pool.ntp.org
          2.rhel.pool.ntp.org
          3.rhel.pool.ntp.org
        STEP_TICKERS

        it { is_expected.to be_file }
        its(:content) { is_expected.to match(step_tickers) }
      end

      it 'sets /etc/sysconfig/ntpd appropriately' do
        on(host, 'cat /etc/sysconfig/ntpd') do
          case host[:platform]
          when %r{el-7-x86_64}
            content = %s(OPTIONS="-g")
          end
          assert_match stdout.chomp, content
        end
      end

      describe file('/etc/sysconfig/ntpdate') do
        it { is_expected.to be_file }
        its(:content) { is_expected.to match(%r{SYNC_HWCLOCK=yes}) }
      end
    end
  end
end

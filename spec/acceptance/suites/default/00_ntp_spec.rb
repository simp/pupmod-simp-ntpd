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
    end
  end
end

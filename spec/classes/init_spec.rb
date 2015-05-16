require 'spec_helper'

describe 'ntpd' do
  let(:facts){{
    :virtual => 'physical',
    :operatingsystem => 'RedHat',
    :lsbmajdistrelease => '7',
    :apache_version => '2.4',
    :fqdn => 'test.host.net',
    :hardwaremodel => 'x86_64',
    :selinux_current_mode => 'enabled',
    :interfaces => 'lo',
    :lsbmajdistrelease => '7',
    :grub_version => '2.0~beta',
    :uid_min => '500'
  }}

  it { should compile.with_all_deps }
  it { should create_concat_build('ntpd') }
  it { should create_concat_fragment('ntpd+ntp.conf').with_content(/fudge\s+127\.127\.1\.0\s+stratum 2/) }

  context 'virtual' do
    let(:facts){{ :virtual => 'kvm' }}

    it { should compile.with_all_deps }
    it { should create_concat_fragment('ntpd+ntp.conf').with_content(/tinker panic 0/) }
  end

  context 'with_auditd' do
    let(:params){{ :use_auditd => true }}

    it { should compile.with_all_deps }
    it { should create_class('auditd') }
    it { should create_auditd__add_rules('ntp') }
  end

  context 'with_servers_hash' do
    let(:params){{
      :servers => {
        'time.bar.baz' => ['prefer'],
        'time.other.net' => []
      }
    }}

    it { should compile.with_all_deps }
    it { should create_concat_fragment('ntpd+ntp.conf').with_content(/fudge\s+127\.127\.1\.0\s+stratum 10/) }
  end
end

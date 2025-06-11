# frozen_string_literal: true

require 'spec_helper'

describe 'ntpd::allow' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { 'test' }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to create_concat__fragment("ntpd_#{title}.allow")
            .with_content(<<~CONTENT,
            restrict 1.2.3.0 mask 255.255.255.0
            restrict 3.4.5.6
            CONTENT
                         )
        }

        it { is_expected.not_to contain_class('iptables') }
        it { is_expected.not_to contain_iptables__listen__udp('allow_ntp_test') }
      end

      context 'with rules set' do
        let(:params) do
          {
            rules: ['flake', 'nomodify']
          }
        end

        it { is_expected.not_to contain_class('iptables') }

        it {
          is_expected.to create_concat__fragment("ntpd_#{title}.allow")
            .with_content(<<~CONTENT,
            restrict 1.2.3.0 mask 255.255.255.0 flake nomodify
            restrict 3.4.5.6 flake nomodify
            CONTENT
                         )
        }
      end

      context 'with firewall => true' do
        let(:params) { { firewall: true } }

        it { is_expected.to contain_class('iptables') }
        it { is_expected.to contain_iptables__listen__udp('allow_ntp_test') }
      end
    end
  end
end

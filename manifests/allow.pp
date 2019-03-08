# Allow access to this server from a particular address or netmask
#
# @param name [String]
#
# @param rules
#   A standard ``ntpd.conf`` restrict rule (``notrust``, etc...)
#
# @param trusted_nets
#   Networks and Hosts to allow
#
# @param firewall
#   If enabled, allow connections from `trusted_nets`
#
define ntpd::allow (
  Optional[Variant[
    String[1],Array[Ntpd::Restrict]
  ]]               $rules        = undef,
  Simplib::Netlist $trusted_nets = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1'] }),
  Boolean          $firewall     = simplib::lookup('simp_options::firewall', { 'default_value' => false})
) {
  include 'ntpd'

  $l_trusted_nets = nets2ddq($trusted_nets)

  concat::fragment { "ntpd_${name}.allow":
    order   => 100,
    target  => '/etc/ntp.conf',
    content => template('ntpd/ntp.allow.erb')
  }

  if $firewall {
    include 'iptables'

    iptables::listen::udp { "allow_ntp_${name}":
      order        => 11,
      trusted_nets => $trusted_nets,
      dports       => 123
    }
  }
}

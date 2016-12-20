# Allow access to this server from a particular address or netmask
#
# @param name [String]
#
# @param trusted_nets
#   Networks and Hosts to allow
#
# @param rules
#   A standard ``ntpd.conf`` restrict append rule (``notrust``, etc...)
#
define ntpd::allow (
  Simplib::Netlist $trusted_nets = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1'] }),
  Optional[String] $rules        = undef,
  Boolean          $firewall     = simplib::lookup('simp_options::firewall', { 'default_value' => false})
) {
  $l_trusted_nets = nets2ddq($trusted_nets)

  concat::fragment { "ntpd_${name}.allow":
    order  => 100,
    target => '/etc/ntpd.conf',
    content => template('ntpd/ntp.allow.erb')
  }

  if $firewall {
    include '::iptables'

    iptables::add_udp_listen { "allow_ntp_${name}":
      order        => 11,
      trusted_nets => $trusted_nets,
      dports       => 123
    }
  }
}

# _Description_
#
# Allow access to this server from a particular address or netmask.
#
# _Variables_
#
# $name
#     Do *not* put '/' in the name.
#
# $client_nets
#     Array of networks to allow access from
# $rules
#     A standard ntpd.conf restrict append rule (notrust, etc...)
define ntpd::allow (
    Array[String]        $trusted_nets = simplib::lookup('simp_options::trusted_nets',
                                           { 'default_value' => ['127.0.0.1', '::1'] }),
    Optional[String]     $rules        = undef,
    Boolean              $use_iptables = simplib::lookup('simp_options::firewall',
                                           { 'default_value' => false})
) {
  $l_trusted_nets = nets2ddq($trusted_nets)

  simpcat_fragment { "ntpd+${name}.allow":
    content => template('ntpd/ntp.allow.erb')
  }

  if $firewall {
    include '::iptables'

    iptables::add_udp_listen { "allow_ntp_${name}":
      order       => '11',
      trusted_nets => $trusted_nets,
      dports      => '123'
    }
  }
}

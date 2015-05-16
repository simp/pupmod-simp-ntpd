# _Description_
#
# Allow access to this server from a particular address or netmask.
#
define ntpd::allow (
# _Variables_
#
# $name
#     Do *not* put '/' in the name.
#
# $client_nets
#     Array of networks to allow access from
    $client_nets = hiera('client_nets'),
# $rules
#     A standard ntpd.conf restrict append rule (notrust, etc...)
    $rules = '',
    $use_iptables = hiera('use_iptables',true)
) {
  $l_client_nets = nets2ddq($client_nets)

  concat_fragment { "ntpd+$name.allow":
    content => template('ntpd/ntp.allow.erb')
  }

  if $use_iptables {
    include 'iptables'

    iptables::add_udp_listen { "allow_ntp_$name":
      order       => '11',
      client_nets => $client_nets,
      dports      => '123'
    }
  }
}

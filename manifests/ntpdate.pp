# == Class: ntpd::ntpdate
#
class ntpd::ntpdate {
  assert_private()

  $bool_to_yes_no = {
    true  => 'yes',
    false => 'no'
  }

  $ntpdate_vars = {
    'sync_hwclock' => $bool_to_yes_no[$::ntpd::ntpdate_sync_hwclock],
    'retry'        => $::ntpd::ntpdate_retry,
    'options'      => $::ntpd::ntpdate_options,
  }
  file { '/etc/sysconfig/ntpdate':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp("${module_name}/ntpdate.epp", $ntpdate_vars)
  }

  $servers = $::ntpd::ntpdate_servers
  if $servers =~ Array {
    $_servers = $servers
  }
  else {
    $_servers = $servers.keys
  }
  file { '/etc/ntp/step-tickers':
    ensure  => 'file',
    content => epp("${module_name}/step-tickers.epp", { 'ntp_servers' => $_servers }),
    notify  => Service['ntpd']
  }
}

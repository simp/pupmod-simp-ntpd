# == Class: ntpd
#
# Set up ntpd in either standalone or server mode.
#
# == Parameters
#
# [*servers*]
# Type: Hash or Array
# Default: {}
#   An array of servers or a hash of server/option pairs providing details
#   for the NTP servers that this system should synchronize with.
# Example:
#   servers => {
#     'time.local.net' => ['iburst','minpoll 4', 'prefer'],
#     # This one will just use $default_options
#     'time.other.net' => []
#   }
#
# [*stratum*]
# Type: Integer
# Default: '2'
#   The stratum for this system. This only comes into play if no external
#   servers are defined and the stratum has to be fudged.
#
# [*log_opts*]
# Type: Array
# Default: ['=syncall','+clockall']
#   A list of log options for refining the system log output. See ntp.conf(5)
#   for details.
#
# [*broadcastdelay*]
# Type: Float
# Default: '0.004'
#   Defalut calibration delay. See ntp.conf(5) for details.
#
# [*default_options*]
# Type: Array
# Default: ['minpoll 4', 'maxpoll 4', 'iburst']
#   The default options that will be added to all servers. Set to an empty
#   array to disable.
#
# [*use_auditd*]
# Type: Boolean
# Default: false
#   If true, enable auditd monitoring of the ntp configuration files.
#   This probably isn't needed in most cases since Puppet controls these files
#   but some systems require it.
#
# [*disable_monitor*]
# Type: Boolean
# Default: true
#   If true, disable the monoitoring facility to prevent amplification
#   attacks using ntpdc monlist command when default restrict does not
#   include the noquery flag. See CVE-2013-5211 for details.
#
# == Authors
#   * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class ntpd (
  $servers = {},
  $stratum = '2',
  $logconfig = ['=syncall','+clockall'],
  $broadcastdelay = '0.004',
  $default_options = ['minpoll 4', 'maxpoll 4', 'iburst'],
  $use_auditd = hiera('use_auditd',false),
  $disable_monitor = true
){
  if !is_array($servers) { validate_hash($servers) }
  else { validate_array($servers) }
  validate_integer($stratum)
  validate_array($logconfig)
  validate_float($broadcastdelay)
  validate_array($default_options)
  validate_bool($use_auditd)
  validate_bool($disable_monitor)

  compliance_map()

  if $use_auditd {
    include '::auditd'
    # Add the audit rules
    auditd::add_rules { 'ntp':
      content => "-w /etc/ntp.conf -p wa -k CFG_ntp
-w /etc/ntp/keys -p wa -k CFG_ntp",
      require => [
        File['/etc/ntp.conf'],
        File['/etc/ntp/keys']
      ]
    }
  }

  simpcat_build { 'ntpd':
    order  => ['ntp.conf', '*.allow'],
    target => '/etc/ntp.conf'
  }

  simpcat_fragment { 'ntpd+ntp.conf':
    content => template('ntpd/ntp.conf.erb')
  }

  file { '/etc/ntp':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    notify => Service['ntpd']
  }

  file { '/etc/ntp/keys':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "\n",
    notify  => Service['ntpd']
  }

  file { '/var/lib/ntp':
    ensure => 'directory',
    owner  => 'ntp',
    group  => 'ntp',
    mode   => '0750',
    notify => Service['ntpd']
  }

  file { '/etc/sysconfig/ntpd':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => "OPTIONS=\"-A -u ntp:ntp -p /var/run/ntpd.pid\"
SYNC_HWCLOCK=yes\n",
    notify  => Service['ntpd']
  }

  file { '/etc/ntp.conf':
    ensure    => 'file',
    owner     => 'root',
    group     => 'ntp',
    mode      => '0600',
    subscribe => Simpcat_build['ntpd'],
    audit     => content,
    notify    => Service['ntpd']
  }

  group { 'ntp':
    ensure    => 'present',
    allowdupe => false,
    gid       => 38,
    before    => Service['ntpd']
  }

  package { 'ntp': ensure => latest }

  service { 'ntpd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['ntp']
  }

  user { 'ntp':
    ensure     => 'present',
    allowdupe  => false,
    gid        => 'ntp',
    home       => '/etc/ntp',
    membership => 'inclusive',
    shell      => '/sbin/nologin',
    uid        => 38,
    before     => Service['ntpd']
  }

}

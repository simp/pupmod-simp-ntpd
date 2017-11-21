# Set up ntpd in either standalone or server mode
#
# @see ntp.conf(5)
#
# @param servers
#   An array of servers or a Hash of server/option pairs providing details
#   for the NTP servers that this system should synchronize with
#
#   * **Example**
#
#     ```
#     servers => {
#       'time.local.net' => ['iburst','minpoll 4', 'prefer'],
#       # This one will just use $default_options
#       'time.other.net' => []
#     }
#     ```
#
# @param stratum
#   The stratum for this system
#
#   * This only comes into play if no external servers are defined and the
#     stratum has to be fudged
#
# @param logconfig
#   A list of options for refining the system log output
#
# @param broadcastdelay
#   Default calibration delay
#
# @param default_options
#   The default options that will be added to all servers
#
#   * Set to an empty array to disable
#
# @param auditd
#   Enable auditd monitoring of the ntp configuration files
#
#   * This probably isn't needed in most cases since Puppet controls these
#     files, but some systems require it
#
# @param disable_monitor
#   Disable the monoitoring facility to prevent amplification attacks using
#   ``ntpdc monlist`` command when default restrict does not include the
#   ``noquery`` flag
#
#   * See CVE-2013-5211 for details
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class ntpd (
  Variant[
    Array[String],
    Hash[String, Array[String]]] $servers         = simplib::lookup('simp_options::ntpd::servers', { 'default_value' => {} }),
  Integer[0]                     $stratum         = 2,
  Array[String]                  $logconfig       = ['=syncall','+clockall'],
  Numeric                        $broadcastdelay  = 0.004,
  Array[String]                  $default_options = ['minpoll 4','maxpoll 4','iburst'],
  Boolean                        $auditd          = simplib::lookup('simp_options::auditd', { 'default_value' => false}),
  Boolean                        $disable_monitor = true
){

  if $auditd {
    include '::auditd'
    # Add the audit rules
    auditd::rule { 'ntp':
      content => "-w /etc/ntp.conf -p wa -k CFG_ntp
-w /etc/ntp/keys -p wa -k CFG_ntp",
      require => [
        Concat['/etc/ntp.conf'],
        File['/etc/ntp/keys']
      ]
    }
  }

  concat { '/etc/ntp.conf':
    owner          => 'root',
    group          => 'ntp',
    mode           => '0600',
    ensure_newline => true,
    warn           => true,
    require        => Package['ntp'],
    notify         => Service['ntpd']
  }

  concat::fragment { 'main_ntp_configuration':
    order   => 0,
    target  => '/etc/ntp.conf',
    content => template("${module_name}/ntp.conf.erb")
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

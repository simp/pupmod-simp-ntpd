# Set up ntpd in either standalone or server mode
#
# @see ntp.conf(5)
#
# @param ntpd_options
#   Options for the ntp daemon, put into `/etc/sysconfig/ntpd`
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
# @param default_restrict
#   The default IPv4 ``restrict`` options
#
# @param default_restrict6
#   The default IPv6 ``restrict`` options
#
# @param admin_hosts
#   Hosts that are allowed unrestricted access via IPv4
#
# @param admin_hosts6
#   Hosts that are allowed unrestricted access via IPv6
#
# @param discard
#   An optional has that can be used to set the average,minimum and
#   monitor options for ``discard``
#
# @param disable_monitor
#   Disable the monitoring facility to prevent amplification attacks using
#   ``ntpdc monlist`` command when default restrict does not include the
#   ``noquery`` flag
#
#   * See CVE-2013-5211 for details
#
# @param manage_ntpdate
#   Manage ntpdate settings
#
# @param ntpdate_servers
#   NTP servers that are used in the ntpdate script at startup
#
# @param ntpdate_sync_hwclock
#   Set to `true` to sync hw clock after successful ntpdate. Set in
#   `/etc/sysconfig/ntpdate`
#
# @param ntpdate_retry
#   Number of retries before giving up. Set in `/etc/sysconfig/ntpdate`
#
# @param ntpdate_options
#   Options for ntpdate. Set in `/etc/sysconfig/ntpdate`
#
# @param auditd
#   Enable auditd monitoring of the ntp configuration files
#
#   * This probably isn't needed in most cases since Puppet controls these
#     files, but some systems require it
#
# @param package_ensure `ensure` parameter for the `ntp` package
#
# @param extra_content
#   An unvalidated String that will be appended to the configuration file
#
# @param config_content
#   The entire content of the configuration file. ALL OTHER ntpd CONFIGURATION
#   OPTIONS WILL BE IGNORED.
#
#   * NOTE: Calls to ``ntpd::allow`` will still add ``restrict`` lines to the
#     configuration.
#
# @author https://github.com/simp/pupmod-simp-ntpd/graphs/contributors
#
class ntpd (
  String[1]               $ntpd_options,
  Ntpd::Servers           $servers              = simplib::lookup('simp_options::ntpd::servers', { 'default_value' => {} }),
  Integer[0]              $stratum              = 2,
  Array[String[1]]        $logconfig            = ['=syncall','+clockall'],
  Numeric                 $broadcastdelay       = 0.004,
  Array[String[1]]        $default_options      = ['minpoll 4','maxpoll 4','iburst'],
  Array[Ntpd::Restrict]   $default_restrict     = ['kod', 'nomodify', 'notrap', 'nopeer', 'noquery'],
  Array[Ntpd::Restrict]   $default_restrict6    = $default_restrict,
  Array[Simplib::IP::V4]  $admin_hosts          = ['127.0.0.1'],
  Array[Simplib::IP::V6]  $admin_hosts6         = ['::1'],
  Optional[Ntpd::Discard] $discard              = undef,
  Boolean                 $disable_monitor      = true,
  Boolean                 $manage_ntpdate       = true,
  Ntpd::Servers           $ntpdate_servers      = $servers,
  Boolean                 $ntpdate_sync_hwclock = true,
  Integer[0]              $ntpdate_retry        = 2,
  Optional[String[1]]     $ntpdate_options      = undef,
  Boolean                 $auditd               = simplib::lookup('simp_options::auditd', { 'default_value' => false}),
  String                  $package_ensure       = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  Optional[String[1]]     $extra_content        = undef,
  Optional[String[1]]     $config_content       = undef
) {

  if $manage_ntpdate {
    include 'ntpd::ntpdate'
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
    target  => '/etc/ntp.conf',
    content => template("${module_name}/ntp.conf.erb"),
    order   => 0,
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
    content => "OPTIONS=\"${ntpd_options}\"\n",
    notify  => Service['ntpd']
  }

  group { 'ntp':
    ensure    => 'present',
    allowdupe => false,
    gid       => 38,
    before    => Service['ntpd']
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

  package { 'ntp':
    ensure => $package_ensure,
    before => User['ntp']
  }

  service { 'ntpd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['ntp']
  }

  if $auditd {
    include '::auditd'

    $_audit_rule = @(EOF)
      -w /etc/ntp.conf -p wa -k CFG_ntp
      -w /etc/ntp/keys -p wa -k CFG_ntp
      | EOF
    # Add the audit rules
    auditd::rule { 'ntp':
      content => $_audit_rule,
      require => [
        Concat['/etc/ntp.conf'],
        File['/etc/ntp/keys']
      ]
    }
  }

}

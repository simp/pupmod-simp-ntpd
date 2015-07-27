Summary: NTP Puppet Module
Name: pupmod-ntpd
Version: 4.1.0
Release: 8
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-auditd >= 4.1.0-3
Requires: pupmod-iptables >= 4.1.0-3
Requires: pupmod-concat >= 4.0.0-0
Requires: puppet >= 3.3.0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-ntpd-test

Prefix: /etc/puppet/environments/simp/modules

%description
This Puppet module provides the capability to configure clients and servers.

Complex server configurations may wish to extend this module to provide the
necessary functionality.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/ntpd

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/ntpd
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/ntpd

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/ntpd

%files
%defattr(0640,root,puppet,0750)
%{prefix}/ntpd

%post
#!/bin/sh

if [ -d %{prefix}/ntpd/plugins ]; then
  /bin/mv %{prefix}/ntpd/plugins %{prefix}/ntpd/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Mon Jul 27 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-8
- Updated the default restrict options to be more restrictive.
- Ref: https://access.redhat.com/articles/1305723

* Thu Feb 19 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-7
- Migrated to the new 'simp' environment.

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-6
- Changed puppet-server requirement to puppet

* Wed Dec 17 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-5
- NTP allow files should use DDQ format for restict entries.

* Tue Oct 07 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-4
- Removed /etc/ntp/ntpservers and added the logic into the main ntp
  configuration file.
- Removed /etc/ntp/step-tickers management

* Sun Jun 22 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-3
- Removed MD5 file checksums for FIPS compliance.

* Fri Jun 20 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-3
- Added support for 'disable_monitor' to fix CVE-2013-5211.

* Thu Jun 12 2014 Nick Markowski <nmarkowski@keywcorp.com> - 4.1.0-2
- Ntp servers can now be passed in as an array of server names or a
  hash of server => 'option' pairs.

* Sat Apr 19 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-1
- Restructured the entire ntpd module.
- Added spec tests.

* Sat Feb 15 2014 Kendall Moore <kmoore@keywcorp.com> 4.1.0-0
- Converted all string booleans to native booleans.

* Tue Jan 28 2014 Kendall Moore <kmoore@keywcorp.com> 4.0.0-5
- Update to remove warnings about IPTables not being detected. This is a
  nuisance when allowing other applications to manage iptables legitimately.

* Mon Oct 07 2013 Kendall Moore <kmoore@keywcorp.com> 4.0.0-4
- Updated all erb templates to properly scope variables.

* Thu Jun 07 2012 Maintenance
4.0.0-3
- Ensure that Arrays in templates are flattened.
- Call facts as instance variables.
- Moved mit-tests to /usr/share/simp...
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Maintenance
4.0.0-2
- Improved test stubs.

* Mon Dec 26 2011 Maintenance
4.0.0-1
- Updated the spec file to not require a separate file list.
- Scoped all of the top level variables.

* Mon Nov 07 2011 Maintenance
4.0.0-0
- Fixed call to rsyslog restart for RHEL6.

* Tue Aug 23 2011 Maintenance - 2.0.0-2
- Updated to set $address = nil by default in ntpd::server::allow.

* Thu May 12 2011 Maintenance - 2.0.0-1
- Updated ntp configuration to properly set /etc/ntp/ntpservers as well as the
  ability to set server options.
- Changed all instances of defined(Class['foo']) to defined('foo') per the
  directions from the Puppet mailing list.
- Updated to use concat_build and concat_fragment types.

* Tue Jan 11 2011 Maintenance
2.0.0-0
- Refactored for SIMP-2.0.0-alpha release

* Fri Dec 10 2010 Maintenance - 1-3
- Ensure that the local stratus is set to 20 instead of 10.
- Added a 'networks' option to ntpd::server::allow that can take an array of
  DDQ entries to set the various servers.
- Added the ability to configure a standalone NTP server and properly spoof the
  stratum advertised. See the ntpd::stock space for example functional usage.

* Tue Oct 26 2010 Maintenance - 1-2
- Converting all spec files to check for directories prior to copy.

* Wed Jun 30 2010 Maintenance
1.0-1
- Fixed a problem in ntp.allow.erb where the 'mask' value was not being set
properly.

* Fri May 21 2010 Maintenance
1.0-0
- Code refactor and doc update.

* Tue Nov 24 2009 Maintenance
0.1-10
- ntpd::server now allows an array of client networks.

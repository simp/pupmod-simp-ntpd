[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/ntpd.svg)](https://forge.puppetlabs.com/simp/ntpd)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/ntpd.svg)](https://forge.puppetlabs.com/simp/ntpd)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-ntpd.svg)](https://travis-ci.org/simp/pupmod-simp-ntpd)

# pupmod-simp-ntpd

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with ntpd](#setup)
    * [What ntpd affects](#what-ntpd-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

Set up ntpd in either standalone or server mode.

## Setup


### What ntpd affects

Manages the following:

* `ntp` package
* `ntp` user/group
* `ntpd` service
* These files and directories:
    * `/etc/ntp.conf`
    * `/etc/ntp/`
    * `/etc/ntp/keys`
    * `/etc/sysconfig/ntpd`
    * `/var/lib/ntp`

### Setup Requirements

This module requires the following:

* [puppetlabs-concat](https://forge.puppet.com/puppetlabs/concat)
* [puppetlabs-stdlib](https://forge.puppet.com/puppetlabs/stdlib)
* [simp-auditd](https://forge.puppet.com/simp/auditd)
* [simp-iptables](https://forge.puppet.com/simp/iptables)
* [simp-simplib](https://forge.puppet.com/simp/simplib)

## Usage

    class { 'ntpd': }

## Reference

### Public Classes

* [ntpd](https://github.com/simp/pupmod-simp-ntpd/blob/master/manifests/init.pp)

#### Parameters

* **`servers`** (`Variant[Array[String], Hash[String, Array[String]]]`) *(defaults to: `simplib::lookup('simp_options::ntpd::servers', { 'default_value' => {} })`)*

An array of servers or a Hash of server/option pairs providing details for the NTP servers that this system should synchronize with

**Example**

```
servers => {
  'time.local.net' => ['iburst','minpoll 4', 'prefer'],
  # This one will just use $default_options
  'time.other.net' => []
}
```

* **`stratum`** (`Integer[0]`) *(defaults to: `2`)*

The stratum for this system

***This only comes into play if no external servers are defined and the stratum has to be fudged***

* **`logconfig`** (`Array[String]`) *(defaults to: `['=syncall','+clockall']`)*

A list of options for refining the system log output

* **`broadcastdelay`** (`Numeric`) *(defaults to: `0.004`)*

Default calibration delay

* **`default\_options`** (`Array[String]`) *(defaults to: `['minpoll 4','maxpoll 4','iburst']`)*

The default options that will be added to all servers

***Set to an empty array to disable***

* **`auditd`** (`Boolean`) *(defaults to: `simplib::lookup('simp_options::auditd', { 'default_value' => false})`)*

Enable auditd monitoring of the ntp configuration files

***This probably isn't needed in most cases since Puppet controls these files, but some systems require it***

* **`disable\_monitor`** (`Boolean`) *(defaults to: `true`)*

Disable the monitoring facility to prevent amplification attacks using `ntpdc monlist` command when default restrict does not include the `noquery` flag

***See CVE-2013-5211 for details***

### Defined Types

* [ntpd::allow](https://github.com/simp/pupmod-simp-ntpd/blob/master/manifests/allow.pp): Allow access to this server from a particular address or netmask

#### Parameters

* **`trusted\_nets`** (`Simplib::Netlist`) *(defaults to: `simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1'] })`)*

Networks and Hosts to allow

* **`rules`** (`Optional[String]`) *(defaults to: `undef`)*

A standard `ntpd.conf` restrict append rule (`notrust`, etc...)

* **`firewall`** (`Boolean`) *(defaults to: `simplib::lookup('simp_options::firewall', { 'default_value' => false})`)*

If enabled, allow connections from `trusted_nets`

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise
Linux and compatible distributions, such as CentOS. Please see the
[`metadata.json` file](./metadata.json) for the most up-to-date list of
supported operating systems, Puppet versions, and module dependencies.

## Development

Please read our [Contribution Guide](http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).

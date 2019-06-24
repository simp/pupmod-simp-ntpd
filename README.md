[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/ntpd.svg)](https://forge.puppetlabs.com/simp/ntpd)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/ntpd.svg)](https://forge.puppetlabs.com/simp/ntpd)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-ntpd.svg)](https://travis-ci.org/simp/pupmod-simp-ntpd)

# pupmod-simp-ntpd

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [Setup](#setup)
  * [What ntpd affects](#what-ntpd-affects)
* [Usage](#usage)
* [Reference](#reference)
* [Limitations](#limitations)
* [Development](#development)

<!-- vim-markdown-toc -->

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

## Usage

    class { 'ntpd': }

## Reference

See the [Reference Documentation](./REFERENCE.md) for full details

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise
Linux and compatible distributions, such as CentOS. Please see the
[`metadata.json` file](./metadata.json) for the most up-to-date list of
supported operating systems, Puppet versions, and module dependencies.

## Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).

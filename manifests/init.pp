# Class: wpa_supplicant
# ===========================
#
# Full description of class wpa_supplicant here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'wpa_supplicant':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class wpa_supplicant (
  String $wireless_interface,
  Boolean $manage_networks = false,
  String $wpa_config_dir = '/etc/wpa_supplicant/',
){

  ensure_resource('package', 'wpa_supplicant', { 'ensure' => 'present' })
  ensure_resource('service', 'wpa_supplicant', { 'ensure' => 'stopped', 'enable' => 'false' })

  if ($wireless_interface != '') {
    $config_name = "wpa_supplicant-nl80211-${wireless_interface}.conf"
    $config_path = "${wpa_config_dir}${config_name}"
    if ($manage_networks) {
      file { "wpa_supplicant config ${wireless_interface}":
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        path    => $config_path,
        content => template('wpa_supplicant/wpa_supplicant.conf.erb'),
        require => Package['wpa_supplicant']
      }
    } else {
      if ! $config_name in $facts['wpa_supplicant']['config_files'] {
        file { "wpa_supplicant config ${wireless_interface}":
          owner   => 'root',
          group   => 'root',
          mode    => '0600',
          path    => $config_path,
          content => template('wpa_supplicant/wpa_supplicant.conf.erb'),
          require => Package['wpa_supplicant']
        }
      }
    }

    ensure_resource('service', "wpa_supplicant-nl80211@${wireless_interface}", { 'ensure' => 'running', 'enable' => 'true' })

  }
}

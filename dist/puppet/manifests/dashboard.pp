# Class: puppet::dashboard
#
# This class installs and configures parameters for Puppet Dashboard
#
# Parameters:
#   $site:
#     This is the fqdn that the dashboard vhost will be reachable by
#
# Actions:
#   Install puppet-dashboard packages
#   Write the database.yml
#   Install the apache vhost
#   Installs logrotate
#
# Requires:
#
# Sample Usage:
#   class { puppet::dashboard: site => 'dashboard.xyz.net; }
#
class puppet::dashboard (
    $site    = "dashboard.${domain}",
    $db_user = "dashboard",
    $db_pw   = 'ch@ng3me'
  ) {

  include ::passenger
  include passenger::params
  include ruby::dev

  $passenger_version=$passenger::params::version
  $gem_path=$passenger::params::gem_path
  $dashboard_site = $site

  package { 'puppet-dashboard':
    ensure => present,
  }

  mysql::db { "dashboard_production":
    db_user => $db_user,
    db_pw   => $db_pw;
  }

  file { '/etc/puppet-dashboard/database.yml':
    ensure  => present,
    content => template('puppet/database.yml.erb'),
    require => Package['puppet-dashboard'],
  }

  file { [ '/usr/share/puppet-dashboard/public', '/usr/share/puppet-dashboard/public/stylesheets', '/usr/share/puppet-dashboard/public/javascript' ]:
    mode => 0755,
    owner => 'www-data',
    group => 'www-data',
    require => Package['puppet-dashboard'],
  }

  #cron { 'dashboard_report_import':
  #  command => 'cd /usr/share/puppet-dashboard; RAILS_ENV=production rake reports:import',
  #  user => 'root',
  #  minute => '*/30', 
  #  require => Package['puppet-dashboard'],
  #}

  apache::vhost { $dashboard_site:
    port     => '80',
    priority => '50',
    docroot  => '/usr/share/puppet-dashboard/public',
    template => 'puppet/puppet-dashboard-passenger.conf.erb',
  }


# managed by the dashboard package
# zleslie:  file {
# zleslie:    "/etc/logrotate.d/puppet-dashboard":
# zleslie:      content => template("puppet/puppet-dashboard.logrotate.erb"),
# zleslie:      owner   => root,
# zleslie:      group   => root,
# zleslie:      mode    => 644;
# zleslie:  }
}

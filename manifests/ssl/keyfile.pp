# == Define: bacula::ssl::keyfile
#
# Type to help the director install new client keys.
#
define bacula::ssl::keyfile {
  file { "keyfile-${name}":
    path    => "${bacula::params::conf_dir}/ssl/${name}_key.pem",
    owner   => $bacula::params::bacula_user,
    group   => '0',
    mode    => '0640',
    content => hiera("bacula_ssl_keyfile_${name}"),
  }
}

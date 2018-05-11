# This define creates a storage autochanger device declaration.  This informs the
# storage daemon which storage devices are available to send client backups to.
#
# @param device_name     - Bacula director configuration for Device option 'Name'
# @param device_type     - Bacula director configuration for Device option 'Device Type'
# @param media_type      - Bacula director configuration for Device option 'Media Type'
# @param device          - Bacula director configuration for Device option 'Archive Device'
# @param label_media     - Bacula director configuration for Device option 'LabelMedia'
# @param random_access   - Bacula director configuration for Device option 'Random Access'
# @param requires_mount  - Bacula director configuration for Device option 'RequiresMount'
# @param automatic_mount - Bacula director configuration for Device option 'AutomaticMount'
# @param removable_media - Bacula director configuration for Device option 'RemovableMedia'
# @param always_open     - Bacula director configuration for Device option 'AlwaysOpen'
# @param maxconcurjobs   - Bacula director configuration for Device option 'Maximum Concurrent Jobs'
# @param conf_dir
# @param device_mode
# @param device_owner
# @param device_seltype
# @param device_count    - Number of devices in the autochanger
# @param director_name
# @param group
# @param reserve_first   - Whether to reserve the first autochanger device for manual operations
# @param changer_device  - Device node for the changer
# @param changer_cmd     - Command to interact with the changer device
# @param max_file_size   - Bacula SD configuration for Device option 'Maximum File Size'
#
define bacula::storage::autochanger_device (
  $device_name      = $name,
  $device_type      = 'File',
  $media_type       = 'File',
  $device           = '/bacula',
  $label_media      = true,
  $random_access    = true,
  $requires_mount   = true,
  $automatic_mount  = true,
  $removable_media  = false,
  $always_open      = false,
  $maxconcurjobs    = '1',
  $max_changer_wait = '180',
  $conf_dir         = $::bacula::conf_dir,
  $device_mode      = '0770',
  $device_owner     = $bacula::bacula_user,
  $device_seltype   = $bacula::device_seltype,
  $device_count     = 1,
  $director_name    = $bacula::director_name,
  $group            = $bacula::bacula_group,
  $reserve_first    = false,
  $changer_device   = '/dev/null',
  $changer_cmd      = '/dev/null',
  $max_file_size    = false,
) {

  concat::fragment { "bacula-storage-autochanger-device-${name}":
    target  => "${conf_dir}/bacula-sd.conf",
    content => template('bacula/bacula-sd-autochanger-device.erb'),
  }

  if $media_type =~ '^File' {
    file { $device:
      ensure  => directory,
      owner   => $device_owner,
      group   => $group,
      mode    => $device_mode,
      seltype => $device_seltype,
    }
  }

  @@bacula::director::storage { "${bacula::storage::storage}-${device_name}":
    address       => $bacula::storage::address,
    port          => $bacula::storage::port,
    password      => $bacula::storage::password,
    device_name   => $device_name,
    media_type    => $media_type,
    autochanger   => true,
    maxconcurjobs => $maxconcurjobs,
    tag           => "bacula-${bacula::storage::director_name}",
  }
}

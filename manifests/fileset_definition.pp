# Define: bareos::fileset_definition
#
# This define installs a configuration file on the backup server.
# Only very simple filesets are supported so far.
#
define bareos::fileset_definition(
  $include_paths,
  $exclude_paths,
  $ignore_changes,
  $acl_support
)
{
  validate_array($include_paths)
  validate_array($exclude_paths)
  validate_bool($ignore_changes)
  validate_bool($acl_support)

  $filename = "${bareos::server::fileset_file_prefix}${title}.conf"
  file { $filename:
    content => template('bareos/server/fileset.erb');
  }
}

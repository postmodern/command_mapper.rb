require 'command_mapper/command'
require 'command_mapper/types/key_value_list'

module CommandMapper
  #
  # Represents the `sudo` command.
  #
  # ## Sudo options:
  #
  # * `-A` - `sudo.ask_password`
  # * `-b` - `sudo.background`
  # * `-C` - `sudo.close_from`
  # * `-E` - `sudo.preserve_env`
  # * `-e` - `sudo.edit`
  # * `-g` - `sudo.group`
  # * `-H` - `sudo.home`
  # * `-h` - `sudo.help`
  # * `-i` - `sudo.simulate_initial_login`
  # * `-k` - `sudo.kill`
  # * `-K` - `sudo.sure_kill`
  # * `-L` - `sudo.list_defaults`
  # * `-l` - `sudo.list`
  # * `-n` - `sudo.non_interactive`
  # * `-P` - `sudo.preserve_group`
  # * `-p` - `sudo.prompt`
  # * `-r` - `sudo.role`
  # * `-S` - `sudo.stdin`
  # * `-s` - `sudo.shell`
  # * `-t` - `sudo.type`
  # * `-U` - `sudo.other_user`
  # * `-u` - `sudo.user`
  # * `-V` - `sudo.version`
  # * `-v` - `sudo.validate`
  #
  # * `[command]` - `sudo.command`
  #
  class Sudo < Command

    option '--askpass', name: :ask_password
    option '--bell'
    option '--background'
    option '--close-from', equals: true
    option '--chdir', equals: true
    option '--preserve-env', equals: true, value: {required: false}
    option '--edit'
    option '--group'
    option '--set-home'
    option '--help'
    option '--host', equals: true
    option '--login'
    option '--remove-timestamp'
    option '--reset-timestamp'
    option '--list'
    option '--non-interactive'
    option '--preserve-groups'
    option '--prompt', equals: true
    option '--chroot', equals: true
    option '--role', equals: true
    option '--stdin'
    option '--shell'
    option '--type', equals: true
    option '--other-user', equals: true
    option '--command-timeout', equals: true
    option '--user', equals: true
    option '--version'
    option '--validate'

    argument :env, repeats: true, value: KeyValueList.new

    argument :command, value: :optional, repeats: true
  end
end

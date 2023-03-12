require 'command_mapper/command'
require 'command_mapper/types/key_value_list'

module CommandMapper
  #
  # Represents the `sudo` command.
  #
  # ## Sudo options:
  #
  # * `-A` - `sudo.askpass`
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

    command "sudo" do
      option "--askpass"
      option "--background"
      option "--bell"
      option "--close-from", equals: true, value: {type: Num.new}
      option "--chdir", equals: true, value: {type: InputDir.new}
      option "--preserve-env", equals: true, value: {type: List.new, required: false}
      option "--edit"
      option "--group", equals: true, value: true
      option "--set-home"
      option "--help"
      option "--host", equals: true, value: true
      option "--login"
      option "--remove-timestamp"
      option "--reset-timestamp"
      option "--list"
      option "--non-interactive"
      option "--preserve-groups"
      option "--prompt", equals: true, value: true
      option "--chroot", equals: true, value: {type: InputDir.new}
      option "--role", equals: true, value: true
      option "--stdin"
      option "--shell"
      option "--type", equals: true, value: true
      option "--command-timeout", equals: true, value: {type: Num.new}
      option "--other-user", equals: true, value: true
      option "--user", equals: true, value: true
      option "--version"
      option "--validate"

      argument :command, required: false, repeats: true
    end

  end
end

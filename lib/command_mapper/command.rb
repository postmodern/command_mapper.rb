require 'command_mapper/types'
require 'command_mapper/argument'
require 'command_mapper/option'

require 'shellwords'

module CommandMapper
  class Command

    include Types

    # The command name.
    #
    # @return [String]
    attr_reader :command_name

    # The optional path to the command.
    #
    # @return [String, nil]
    attr_reader :command_path

    # The environment variables to execute the command with.
    #
    # @return [Hash{String => String}]
    attr_reader :command_env

    # The subcommand's options and arguments.
    #
    # @return [Command, nil]
    attr_reader :command_subcommand

    #
    # Initializes the command.
    #
    # @param [Hash{Symbol => Object}] params
    #   The option and argument values.
    #
    # @param [String] command_name
    #   Overrides the command with a custom command name.
    #
    # @param [String, nil] command_path
    #   Overrides the command with a custom path to the command.
    #
    # @param [Hash{String => String}] command_env
    #   Custom environment variables to pass to the command.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keywords arguments. These will be used to populate
    #   {#options} and {#arguments}, along with `params`.
    #
    # @yield [self]
    #   The newly initialized command.
    #
    # @yieldparam [Command] self
    #
    # @example with a symbol Hash
    #   MyCommand.new({foo: 'bar', baz: 'qux'})
    #
    # @example with a keyword arguments
    #   MyCommand.new(foo: 'bar', baz: 'qux')
    #
    # @example with a custom env Hash:
    #   MyCommand.new({foo: 'bar', baz: 'qux'}, env: {'FOO' =>'bar'})
    #   MyCommand.new(foo: 'bar', baz: 'qux', env: {'FOO' => 'bar'})
    #
    def initialize(params={}, command_name: self.class.command_name,
                              command_path: nil,
                              command_env:  {},
                              **kwargs)
      @command_name = command_name
      @command_path = command_path
      @command_env  = command_env

      params = params.merge(kwargs)

      params.each do |name,value|
        self[name] = value
      end

      yield self if block_given?
    end

    #
    # Initializes and runs the command.
    #
    # @param [Hash{Symbol => Object}] params
    #   The option values.
    #
    # @yield [self]
    #   The newly initialized command.
    #
    # @yieldparam [Command] self
    #
    # @return [Boolean, nil]
    #
    def self.run(params={},**kwargs,&block)
      command = new(params,**kwargs,&block)
      command.run_command
    end

    #
    # Initializes and spawns the command as a separate process, returning the
    # PID of the process.
    #
    # @param [Hash{Symbol => Object}] params
    #   The option values.
    #
    # @yield [self]
    #   The newly initialized command.
    #
    # @yieldparam [Command] self
    #
    # @return [Integer]
    #   The PID of the new command process.
    #
    # @raise [Errno::ENOENT]
    #   The command could not be found.
    #
    # @since 0.2.0
    #
    def self.spawn(params={},**kwargs,&block)
      command = new(params,**kwargs,&block)
      command.spawn_command
    end

    #
    # Initializes and runs the command in a shell and captures all stdout
    # output.
    #
    # @param [Hash{Symbol => Object}] params
    #   The option values.
    #
    # @yield [self]
    #   The newly initialized command.
    #
    # @yieldparam [Command] self
    #
    # @return [String]
    #   The stdout output of the command.
    #
    def self.capture(params={},**kwargs,&block)
      command = new(params,**kwargs,&block)
      command.capture_command
    end

    #
    # Initializes and executes the command and returns an IO object to it.
    #
    # @param [Hash{Symbol => Object}] params
    #   The option values.
    #
    # @yield [self]
    #   The newly initialized command.
    #
    # @yieldparam [Command] self
    #
    # @return [IO]
    #
    def self.popen(params={}, mode: 'r', **kwargs,&block)
      command = new(params,**kwargs,&block)
      command.popen_command
    end

    #
    # Initializes and runs the command through `sudo`.
    #
    # @param [Hash{Symbol => Object}] params
    #   The option values.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments for {#initialize}.
    #
    # @yield [self]
    #   The newly initialized command.
    #
    # @yieldparam [Command] self
    #
    # @return [Boolean, nil]
    #
    def self.sudo(params={}, sudo: {}, **kwargs,&block)
      command = new(params,**kwargs,&block)
      command.sudo_command(**sudo)
    end

    #
    # Gets or sets the command name.
    #
    # @param [#to_s] new_name
    #   The optional new command name.
    #
    # @return [String]
    #   The command name.
    #
    # @raise [NotImplementedError]
    #   The command class did not call {command}.
    #
    # @api semipublic
    #
    def self.command_name
      @command_name || if superclass < Command
                         superclass.command_name
                       else
                         raise(NotImplementedError,"#{self} did not call command(...)")
                       end
    end

    #
    # @param [#to_s] new_command_name
    #
    # @yield [self]
    #
    # @example
    #   command 'grep'
    #   # ...
    #
    # @example
    #   command 'grep' do
    #     option "--regexp", equals: true, value: true
    #     # ...
    #   end
    #
    # @api public
    #
    def self.command(new_command_name,&block)
      @command_name = new_command_name.to_s.freeze
      yield self if block_given?
    end

    #
    # All defined options.
    #
    # @return [Hash{Symbol => Option}]
    #
    # @api semipublic
    #
    def self.options
      @options ||= if superclass < Command
                     superclass.options.dup
                   else
                     {}
                   end
    end

    #
    # Determines if an option with the given name has been defined.
    #
    # @param [Symbol] name
    #   The given name.
    #
    # @return [Boolean]
    #   Specifies whether an option with the given name has been defined.
    #
    # @api semipublic
    #
    # @since 0.2.0
    #
    def self.has_option?(name)
      options.has_key?(name)
    end

    #
    # Defines an option for the command.
    #
    # @param [String] flag
    #   The option's command-line flag.
    #
    # @param [Symbol, nil] name
    #   The option's name.
    #
    # @param [Hash, nil] value
    #   The option's value.
    #
    # @option value [Boolean] :required
    #   Specifies whether the option requires a value or not.
    #
    # @option value [Types:Type, Hash, nil] :type
    #   The explicit type for the option's value.
    #
    # @param [Boolean] repeats
    #   Specifies whether the option can be given multiple times.
    #
    # @param [Boolean] equals
    #   Specifies whether the option's flag and value should be separated with a
    #   `=` character.
    #
    # @param [Boolean] value_in_flag
    #   Specifies that the value should be appended to the option's flag
    #   (ex: `-Fvalue`).
    #
    # @api public
    #
    # @example Defining an option:
    #   option '--foo'
    #
    # @example Defining an option with a custom name:
    #   option '-F', name: :foo
    #
    # @example Defining an option who's value is required:
    #   option '--file', value: true
    #
    # @example Defining an option who's value is optional:
    #   option '--file', value: {required: false}
    #
    # @example Defining an `-Fvalue` option:
    #   option '--foo', value: true, value_in_flag: true
    #
    # @example Defining an `--opt=value` option:
    #   option '--foo', equals: true, value: true
    #
    # @example Defining an option that can be repeated multiple times:
    #   option '--foo', repeats: true
    #
    # @example Defining an option that takes a comma-separated list:
    #   option '--list', value: List.new
    #
    # @raise [ArgumentError]
    #   The option flag conflicts with a pre-existing internal method, or
    #   another argument or subcommand.
    #
    def self.option(flag, name: nil, value: nil, repeats: false,
                          # formatting options
                          equals:        nil,
                          value_in_flag: nil,
                          &block)
      option = Option.new(flag, name:    name,
                                value:   value,
                                repeats: repeats,
                                # formatting options
                                equals:        equals,
                                value_in_flag: value_in_flag,
                                &block)

      if is_internal_method?(option.name)
        if name
          raise(ArgumentError,"option #{flag.inspect} with name #{name.inspect} cannot override the internal method with same name: ##{option.name}")
        else
          raise(ArgumentError,"option #{flag.inspect} maps to method name ##{option.name} and cannot override the internal method with same name: ##{option.name}")
        end
      elsif has_argument?(option.name)
        raise(ArgumentError,"option #{flag.inspect} with name #{option.name.inspect} conflicts with another argument with the same name")
      elsif has_subcommand?(option.name)
        raise(ArgumentError,"option #{flag.inspect} with name #{option.name.inspect} conflicts with another subcommand with the same name")
      end

      self.options[option.name] = option
      attr_accessor option.name
    end

    #
    # All defined options.
    #
    # @return [Hash{Symbol => Argument}]
    #
    # @api semipublic
    #
    def self.arguments
      @arguments ||= if superclass < Command
                       superclass.arguments.dup
                     else
                       {}
                     end
    end

    #
    # Determines if an argument with the given name has been defined.
    #
    # @param [Symbol] name
    #   The given name.
    #
    # @return [Boolean]
    #   Specifies whether an argument with the given name has been defined.
    #
    # @api semipublic
    #
    # @since 0.2.0
    #
    def self.has_argument?(name)
      arguments.has_key?(name)
    end

    #
    # Defines an option for the command.
    #
    # @param [Symbol] name
    #
    # @param [Boolean] required
    #   Specifies whether the argument is required or can be omitted.
    #
    # @param [Types::Type, Hash, nil] type
    #   The explicit type for the argument.
    #
    # @param [Boolean] repeats
    #   Specifies whether the option can be repeated multiple times.
    #
    # @api public
    #
    # @example Define an argument:
    #   argument :file
    #
    # @example Define an argument that can be specified multiple times:
    #   argument :files, repeats: true
    #
    # @example Define an optional argument:
    #   argument :file, required: false
    #
    # @raise [ArgumentError]
    #   The argument name conflicts with a pre-existing internal method, or
    #   another option or subcommand.
    #
    def self.argument(name, required: true, type: Str.new, repeats: false)
      name     = name.to_sym
      argument = Argument.new(name, required: required,
                                    type:     type,
                                    repeats:  repeats)

      if is_internal_method?(argument.name)
        raise(ArgumentError,"argument #{name.inspect} cannot override internal method with same name: ##{argument.name}")
      elsif has_option?(argument.name)
        raise(ArgumentError,"argument #{name.inspect} conflicts with another option with the same name")
      elsif has_subcommand?(argument.name)
        raise(ArgumentError,"argument #{name.inspect} conflicts with another subcommand with the same name")
      end

      self.arguments[argument.name] = argument
      attr_accessor name
    end

    #
    # All defined subcommands.
    #
    # @return [Hash{Symbol => Command}]
    #
    # @api semipublic
    #
    def self.subcommands
      @subcommands ||= if superclass < Command
                         superclass.subcommands.dup
                       else
                         {}
                       end
    end

    #
    # Determines if a subcommand with the given name has been defined.
    #
    # @param [Symbol] name
    #   The given name.
    #
    # @return [Boolean]
    #   Specifies whether a subcommand with the given name has been defined.
    #
    # @api semipublic
    #
    # @since 0.2.0
    #
    def self.has_subcommand?(name)
      subcommands.has_key?(name)
    end

    #
    # Defines a subcommand.
    #
    # @param [String] name
    #   The name of the subcommand.
    #
    # @yield [subcommand]
    #   The given block will be used to populate the subcommand's options.
    #
    # @yieldparam [Command] subcommand
    #   The newly created subcommand class.
    #
    # @note
    #   Also defines a class within the command class using the subcommand's
    #   name.
    #
    # @example Defining a sub-command:
    #   class Git
    #     command 'git' do
    #       subcommand 'clone' do
    #         option '--bare'
    #         # ...
    #       end
    #     end
    #   end
    #
    # @raise [ArgumentError]
    #   The subcommand name conflicts with a pre-existing internal method, or
    #   another option or argument.
    #
    def self.subcommand(name,&block)
      name            = name.to_s
      method_name     = name.tr('-','_')
      class_name      = name.split(/[_-]+/).map(&:capitalize).join
      subcommand_name = method_name.to_sym

      if is_internal_method?(method_name)
        raise(ArgumentError,"subcommand #{name.inspect} maps to method name ##{method_name} and cannot override the internal method with same name: ##{method_name}")
      elsif has_option?(subcommand_name)
        raise(ArgumentError,"subcommand #{name.inspect} conflicts with another option with the same name")
      elsif has_argument?(subcommand_name)
        raise(ArgumentError,"subcommand #{name.inspect} conflicts with another argument with the same name")
      end

      subcommand_class = Class.new(Command)
      subcommand_class.command(name)
      subcommand_class.class_eval(&block)

      self.subcommands[subcommand_name] = subcommand_class
      const_set(class_name,subcommand_class)

      define_method(method_name) do |&block|
        if block then @command_subcommand = subcommand_class.new(&block)
        else          @command_subcommand
        end
      end

      define_method(:"#{method_name}=") do |options|
        @command_subcommand = if options
                                subcommand_class.new(options)
                              end
      end
    end

    #
    # Gets the value of an option or an argument.
    #
    # @param [Symbol] name
    #
    # @return [Object]
    #
    # @raise [ArgumentError]
    #   The given name was not match any option or argument.
    #
    def [](name)
      name = name.to_s

      if respond_to?(name)
        send(name)
      else
        raise(ArgumentError,"#{self.class} does not define ##{name}")
      end
    end

    #
    # Sets an option or an argument with the given name.
    #
    # @param [Symbol] name
    #
    # @param [Object] value
    #
    # @return [Object]
    #
    # @raise [ArgumentError]
    #   The given name was not match any option or argument.
    #
    def []=(name,value)
      if respond_to?("#{name}=")
        send("#{name}=",value)
      else
        raise(ArgumentError,"#{self.class} does not define ##{name}=")
      end
    end

    #
    # Returns an Array of command-line arguments for the command.
    #
    # @return [Array<String>]
    #
    # @raise [ArgumentReqired]
    #   A required argument was not set.
    #
    def command_argv
      argv = [@command_path || @command_name]

      self.class.options.each do |name,option|
        unless (value = self[name]).nil?
          option.argv(argv,value)
        end
      end

      if @command_subcommand
        # a subcommand takes precedence over any command arguments
        argv.concat(@command_subcommand.command_argv)
      else
        additional_args = []

        self.class.arguments.each do |name,argument|
          value = self[name]

          if value.nil?
            if argument.required?
              raise(ArgumentRequired,"argument #{name} is required")
            end
          else
            argument.argv(additional_args,value)
          end
        end

        if additional_args.any? { |arg| arg.start_with?('-') }
          # append a '--' separator if any of the arguments start with a '-'
          argv << '--'
        end

        argv.concat(additional_args)
      end

      return argv
    end

    #
    # Escapes any shell control-characters so that it can be ran in a shell.
    #
    # @return [String]
    #   The shell-escaped command.
    #
    def command_string
      escaped_command = Shellwords.shelljoin(command_argv)

      unless @command_env.empty?
        escaped_env = @command_env.map { |name,value|
          "#{Shellwords.shellescape(name)}=#{Shellwords.shellescape(value)}"
        }.join(' ')

        escaped_command = "#{escaped_env} #{escaped_command}"
      end

      return escaped_command
    end

    #
    # Runs the command.
    #
    # @return [Boolean, nil]
    #
    def run_command
      Kernel.system(@command_env,*command_argv)
    end

    #
    # Spawns the command as a separate process, returning the PID of the
    # process.
    #
    # @return [Integer]
    #   The PID of the new command process.
    #
    # @raise [Errno::ENOENT]
    #   The command could not be found.
    #
    # @since 0.2.0
    #
    def spawn_command
      Process.spawn(@command_env,*command_argv)
    end

    #
    # Runs the command in a shell and captures all stdout output.
    #
    # @return [String]
    #   The stdout output of the command.
    #
    def capture_command
      `#{command_string}`
    end

    #
    # Executes the command and returns an IO object to it.
    #
    # @return [IO]
    #
    def popen_command(mode=nil)
      if mode then IO.popen(@command_env,command_argv,mode)
      else         IO.popen(@command_env,command_argv)
      end
    end

    #
    # Runs the command through `sudo`.
    #
    # @param [Hash{Symbol => Object}] sudo_params
    #   Additional keyword arguments for {Sudo#initialize}.
    #
    # @return [Boolean, nil]
    #
    def sudo_command(**sudo_kwargs,&block)
      sudo_params = sudo_kwargs.merge(command: command_argv)

      Sudo.run(sudo_params, command_env: @command_env, &block)
    end

    #
    # @see #argv
    #
    def to_a
      command_argv
    end

    #
    # @see #shellescape
    #
    def to_s
      command_string
    end

    private

    #
    # Determines if there is an internal method of the same name.
    #
    # @param [#to_sym] name
    #   The method name.
    #
    # @return [Boolean]
    #
    def self.is_internal_method?(name)
      Command.instance_methods(false).include?(name.to_sym)
    end

  end
end

require 'command_mapper/sudo'

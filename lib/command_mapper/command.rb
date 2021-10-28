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

    # The option values to execute the command with.
    #
    # @return [Hash{String => Object}]
    attr_reader :command_options

    # The argument values to execute the command with.
    #
    # @return [Hash{String => Object}]
    attr_reader :command_arguments

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
    # @param [Hash{String => String}] env
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
    # Runs the command in a shell and captures all stdout output.
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
    # Executes the command and returns an IO object to it.
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
    # Initializes and runs the command through sudo.
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
      @command_name || raise(NotImplementedError,"#{self} did not call command(...)")
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
    #     option "--regexp", equals: true, value: :required
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
    # Defines an option for the command.
    #
    # @param [String] flag
    #
    # @param [Hash{Symbol => Object}] value
    #
    # @option value [Types::Type, Hash, :required, :optional, nil] value
    #   The format of the option's value.
    #
    # @param [Boolean] equals
    #   Specifies whether the option is of the form `--opt=value` or
    #   `--opt value`.
    #
    # @param [Boolean] repeats
    #   Specifies whether the option can be repeated multiple times.
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
    #   option '--file', value: :required
    #
    # @example Defining an option who's value is optional:
    #   option '--file', value: :optional
    #
    # @example Defining an `--opt=value` option:
    #   option '--foo', equals: true, value: :required
    #
    # @example Defining an option that can be repeated multiple times:
    #   option '--foo', repeats: true
    #
    # @example Defining an option that takes a comma-separated list:
    #   option '--list', value: List.new
    #
    # @raise [ArgumentError]
    #   The option flag conflicts with a pre-existing internal method.
    #
    def self.option(flag, name: nil, value: nil, repeats: false, equals: false, &block)
      option = Option.new(flag, name:    name,
                                equals:  equals,
                                value:   value,
                                repeats: repeats,
                                &block)

      self.options[option.name] = option

      if is_internal_method?(option.name)
        if name
          raise(ArgumentError,"option #{flag.inspect} with name #{name.inspect} cannot override the internal method with same name: ##{option.name}")
        else
          raise(ArgumentError,"option #{flag.inspect} maps to method name ##{option.name} and cannot override the internal method with same name: ##{option.name}")
        end
      end

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
    # Defines an option for the command.
    #
    # @param [Symbol] name
    #
    # @param [Types::Type, Hash, :required, :optional] value
    #   The explicit value type for the argument.
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
    #   argument :file, value: {required: false}
    #
    # @raise [ArgumentError]
    #   The argument name conflicts with a pre-existing internal method.
    #
    def self.argument(name, value: :required, repeats: false)
      name     = name.to_sym
      argument = Argument.new(name, value: value, repeats: repeats)

      self.arguments[argument.name] = argument

      if is_internal_method?(argument.name)
        raise(ArgumentError,"argument #{name.inspect} cannot override internal method with same name: ##{argument.name}")
      end

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
    #   The subcommand name conflicts with a pre-existing internal method.
    #
    def self.subcommand(name,&block)
      name = name.to_s

      subcommand_class = Class.new(Command)
      subcommand_class.command(name)
      subcommand_class.class_eval(&block)

      method_name = name.tr('-','_')
      class_name  = name.split(/[_-]+/).map(&:capitalize).join

      self.subcommands[method_name.to_sym] = subcommand_class
      const_set(class_name,subcommand_class)

      if is_internal_method?(method_name)
        raise(ArgumentError,"subcommand #{name.inspect} maps to method name ##{method_name} and cannot override the internal method with same name: ##{method_name}")
      end

      define_method(method_name) do |&block|
        if block then @command_subcommand = subcommand_class.new(&block)
        else          @command_subcommand
        end
      end

      define_method(:"#{method_name}=") do |options|
        @command_subcommand = subcommand_class.new(options)
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

          if value.nil? && argument.value.required?
            raise(ArgumentRequired,"argument #{name} is required")
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
    # Initializes and runs the command.
    #
    # @return [Boolean, nil]
    #
    def run_command
      system(@command_env,*command_argv)
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
    # Initializes and runs the command through sudo.
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

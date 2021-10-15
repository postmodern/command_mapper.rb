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
    attr_reader :env

    # The option values to execute the command with.
    #
    # @return [Hash{String => Object}]
    attr_reader :options

    # The argument values to execute the command with.
    #
    # @return [Hash{String => Object}]
    attr_reader :arguments

    # The subcommand's options and arguments.
    #
    # @return [Command, nil]
    attr_reader :subcommand

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
                              env:     {},
                              **kwargs)
      @command_name = command_name
      @command_path = command_path

      @options    = {}
      @subcommand = nil
      @arguments  = {}

      params = params.merge(kwargs)

      params.each do |name,value|
        self[name] = value
      end

      @env = env

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
      command.run!
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
      command.capture!
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
      command.popen!
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
      command.sudo!(sudo)
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
    # @option value [Types::Value, Hash, :required, :optional, nil] value
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
    def self.option(flag, name: nil, value: nil, repeats: false, equals: false, &block)
      option = Option.new(flag, name:    name,
                                equals:  equals,
                                value:   value,
                                repeats: repeats,
                                &block)

      self.options[option.name] = option

      define_method(option.name) do
        @options[option.name]
      end

      define_method(:"#{option.name}=") do |value|
        @options[option.name] = value
      end
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
    # @param [Types::Value, Hash, :required, :optional] value
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
    def self.argument(name, value: :required, repeats: false)
      name     = name.to_sym
      argument = Argument.new(name, value: value, repeats: repeats)

      self.arguments[argument.name] = argument

      define_method(name)        {         @arguments[argument.name]         }
      define_method(:"#{name}=") { |value| @arguments[argument.name] = value }
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
    def self.subcommand(name,&block)
      name = name.to_s

      subcommand_class = Class.new(Command)
      subcommand_class.command(name)
      subcommand_class.class_eval(&block)

      method_name = name.tr('-','_')
      class_name  = name.split(/[_-]+/).map(&:capitalize).join

      self.subcommands[method_name.to_sym] = subcommand_class
      const_set(class_name,subcommand_class)

      define_method(method_name) do |&block|
        if block then @subcommand = subcommand_class.new(&block)
        else          @subcommand
        end
      end

      define_method(:"#{method_name}=") do |options|
        @subcommand = subcommand_class.new(options)
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
    def argv
      argv = [@command_path || @command_name]

      @options.each do |name,value|
        option = self.class.options.fetch(name)

        option.argv(argv,value)
      end

      if @subcommand
        # a subcommand takes precedence over any command arguments
        argv.concat(@subcommand.argv)
      else
        additional_args = []

        @arguments.each do |name,value|
          argument = self.class.arguments.fetch(name)

          argument.argv(additional_args,value)
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
    def shellescape
      escaped_command = Shellwords.shelljoin(argv)

      unless @env.empty?
        escaped_env = @env.map { |name,value|
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
    def run!
      system(@env,*argv)
    end

    #
    # Runs the command in a shell and captures all stdout output.
    #
    # @return [String]
    #   The stdout output of the command.
    #
    def capture!
      `#{shellescape}`
    end

    #
    # Executes the command and returns an IO object to it.
    #
    # @return [IO]
    #
    def popen!(mode=nil)
      if mode then IO.popen(@env,argv,mode)
      else         IO.popen(@env,argv)
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
    def sudo!(sudo_params={},&block)
      Sudo.run(sudo_params.merge(command: argv), env: @env, &block)
    end

    #
    # @see #argv
    #
    def to_a
      argv
    end

    #
    # @see #shellescape
    #
    def to_s
      shellescape
    end

  end
end

require 'command_mapper/sudo'

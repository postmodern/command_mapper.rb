require 'command_mapper/types'
require 'command_mapper/argument'
require 'command_mapper/option'

require 'shellwords'

module CommandMapper
  class Command

    include Types

    #
    # Initializes the command.
    #
    # @param [Hash{Symbol => Object}] params
    #   The option values.
    #
    # @param [String] command
    #   Overrides the command name.
    #
    # @param [Hash{String => String,nil}] env
    #   Custom environment variables to pass to the command.
    #
    # @yield [self]
    #   The newly initialized command.
    #
    # @yieldparam [Command] self
    #
    def initialize(params={}, command: self.class.command, env: {})
      @options    = {}
      @subcommand = nil
      @arguments  = {}

      params.each do |name,value|
        self[name] = value
      end

      @command = command
      @env     = env

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

      system(command.env,*command.argv)
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

      `#{command.shellescape}`
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

      IO.popen(command.env,command.argv,mode)
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

      Sudo.run(sudo.merge(env: command.env, command: command.argv))
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
    # @api public
    #
    def self.command(new_name=nil)
      if new_name
        @command = new_name.to_s.freeze
      else
        @command || raise(NotImplementedError,"#{self} did not set command")
      end
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
    #     command 'git'
    #   
    #     subcommand 'clone' do
    #       option '--bare'
    #       # ...
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
      argv = [@command]

      @options.each do |name,value|
        option = self.class.options.fetch(name)

        argv.concat(option.argv(value))
      end

      if @subcommand
        # a subcommand takes precedence over any command arguments
        argv.concat(@subcommand.argv)
      else
        additional_args = []

        @arguments.each do |name,value|
          argument = self.class.arguments.fetch(name)

          additional_args.concat(argument.argv(value))
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
      Shellwords.shelljoin(argv)
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

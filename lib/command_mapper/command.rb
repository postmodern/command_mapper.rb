require 'command_mapper/formats'
require 'command_mapper/argument'
require 'command_mapper/option'

require 'shellwords'

module CommandMapper
  class Command

    include Formats

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
      @arguments  = {}
      @subcommand = nil

      @command = command
      @env     = env

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
    def self.popen(params={}, **kwargs,&block)
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
    # @option value [Class] :format
    #   The format of the option's value.
    #
    # @option value [Boolean] :required (true)
    #   Specifies whether the option's value is required.
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
    #   option '--file', value: true
    #
    # @example Defining an option who's value is optional:
    #   option '--file', value: {required: false}
    #
    # @example Defining an `--opt=value` option:
    #   option '--foo', equals: true, value: true
    #
    # @example Defining an option that can be repeated multiple times:
    #   option '--foo', repeats: true
    #
    # @example Defining an option that takes a comma-separated list:
    #   option '--list', value: {format: List.new(',')}
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
    # @param [Class, nil] format
    #   The format of the option's value.
    #
    # @param [Boolean] required (true)
    #   Specifies whether the option's value is required.
    #
    # @param [Boolean] repeats
    #   Specifies whether the option can be repeated multiple times.
    #
    # @api public
    #
    # @example Define an argument:
    #   argument :file, required: true
    #
    # @example Define an argument that can be specified multiple times:
    #   argument :files, repeats: true
    #
    # @example Define an optional argument:
    #   argument :file
    #
    def self.argument(name, format: nil, required: true, repeats: false)
      argument = Argument.new(name, format:   format,
                                    required: required,
                                    repeats:  repeats)

      self.arguments[name] = argument

      define_method(name)        {         @options[name]         }
      define_method(:"#{name}=") { |value| @options[name] = value }
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
      subcommand_class = Class.new(Command)
      subcommand_class.command(name)
      subcommand_class.class_eval(&block)

      subcommand_method_name = name.to_s.tr('-','_')
      subcommand_class_name  = name.to_s.split(/[_-]+/).map(&:capitalize).join

      const_set(subcommand_class_name,subcommand_class)

      define_method(subcommand_method_name) do |&block|
        if block then @subcommand = subcommand_class.new(&block)
        else          @subcommand
        end
      end

      define_method(:"#{subcommand_method_name}=") do |options|
        @subcommand = subcommand_class.new(options)
      end
    end

    def [](name)
      @options.fetch(name) do
        @arguments[name]
      end
    end

    def []=(name,value)
      if respond_to?("#{name}=")
        send("#{name}=",value)
      else
        raise(ArgumentError,"#{self.class} does not define ##{name}=")
      end
    end

    def argv
      args = [@command]

      @options.each do |name,value|
        unless value.nil?
          option = self.class.options.fetch(name) do
            raise(UnknownOption,"unknown option name: #{name.inspect}")
          end

          args.concat(option.argv(value))
        end
      end

      if @subcommand
        # a subcommand takes precedence over any command arguments
        args.concat(@subcommand.argv)
      else
        additional_args = []

        @arguments.each do |name,value|
          unless value.nil?
            argument = self.class.arguments.fetch(name) do
              raise(UnknownArgument,"unknown argument name: #{name.inspect}")
            end

            additional_args.concat(argument.argv(value))
          end
        end

        if additional_args.any? { |token| token.start_with?('-') }
          additional_args.prepend('--')
        end

        argv.concat(additiional_args)
      end

      return args
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

    #
    # Runs the command.
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
    def popen!
      IO.popen(@env,*argv)
    end

    #
    # Runs the command through `sudo`.
    #
    # @param [Hash{Symbol => Object}] sudo_options
    #   Additional options for {Sudo}.
    #
    # @return [Boolean, nil]
    #   Indicates whether the `sudo` command successfully ran.
    #   Returns `nil` when `sudo` is not installed.
    #
    def sudo!(sudo_options={})
      sudo = Sudo.new(sudo_options)
      sudo.env     = @env
      sudo.command = argv
      sudo.run!
    end

  end
end

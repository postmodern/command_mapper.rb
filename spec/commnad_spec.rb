require 'spec_helper'
require 'command_mapper/command'

describe CommandMapper::Command do
  module TestCommand
    class WithCommandName < CommandMapper::Command
      command 'foo'
    end

    class NoCommandName < CommandMapper::Command
    end
  end

  describe ".command_name" do
    subject { command_class }

    context "when @command_name has been set" do
      let(:command_class) { TestCommand::WithCommandName }

      it "must return the defined command name" do
        expect(subject.command_name).to eq('foo')
      end

      it "must freeze the given command name" do
        expect(subject.command_name).to be_frozen
      end
    end

    context "when no .command has been defined" do
      let(:command_class) { TestCommand::NoCommandName }

      it "must raise NotImplementedError" do
        expect {
          subject.command_name
        }.to raise_error(NotImplementedError,"#{command_class} did not call command(...)")
      end
    end
  end

  describe ".command_name" do
    subject { command_class }

    context "when @command_name has been set" do
      let(:command_class) { TestCommand::WithCommandName }

      it "must set .command_name" do
        expect(subject.command_name).to eq('foo')
      end
    end
  end

  module TestCommand
    class EmptyCommand < CommandMapper::Command
    end
  end

  describe ".options" do
    subject { command_class }

    context "when the command has no defined options" do
      let(:command_class) { TestCommand::EmptyCommand }

      it { expect(subject.options).to be_empty }
    end

    context "and when the command inherits from another command class" do
      module TestCommand
        class BaseClassWithOptions < CommandMapper::Command
          option "--foo"
          option "--bar"
        end

        class InheritedOptions < BaseClassWithOptions
        end
      end

      let(:command_class) { TestCommand::InheritedOptions }
      let(:command_superclass) { TestCommand::BaseClassWithOptions }

      it "must copy the options defined in the superclass" do
        expect(subject.options).to eq(command_superclass.options)
      end

      context "and when the class defines options of it's own" do
        module TestCommand
          class InheritsAndDefinesOptions < BaseClassWithOptions
            option "--baz"
          end
        end

        let(:command_class) { TestCommand::InheritsAndDefinesOptions }

        it "must copy the options defined in the superclass" do
          expect(subject.options).to include(command_superclass.options)
        end

        it "must define it's own options" do
          expect(command_class.options[:baz]).to be_kind_of(CommandMapper::Option)
        end

        it "must not modify the superclass's options" do
          expect(command_superclass.options[:baz]).to be(nil)
        end
      end
    end
  end

  describe ".option" do
    module TestCommand
      class DefinesItsOwnOptions < CommandMapper::Command
        command 'test' do
          option '--foo'
          option '--bar'
        end
      end
    end

    let(:command_class) { TestCommand::DefinesItsOwnOptions }

    subject { command_class }

    it "must add options to .options" do
      expect(subject.options[:foo]).to be_kind_of(CommandMapper::Option)
      expect(subject.options[:foo].flag).to eq('--foo')

      expect(subject.options[:bar]).to be_kind_of(CommandMapper::Option)
      expect(subject.options[:bar].flag).to eq('--bar')
    end

    it "must define a reader method for each option" do
      expect(subject.instance_methods(false)).to include(:foo)
      expect(subject.instance_methods(false)).to include(:bar)
    end

    it "must define a writter method for each option" do
      expect(subject.instance_methods(false)).to include(:foo=)
      expect(subject.instance_methods(false)).to include(:bar=)
    end

    describe "reader method" do
      subject { command_class.new }

      let(:value) { "test_reading" }

      before do
        subject.instance_variable_get("@command_options")[:foo] = value
      end

      it "must read the options value from @options" do
        expect(subject.foo).to be(value)
      end
    end

    describe "writter method" do
      subject { command_class.new }

      let(:value) { "test_writing" }

      before { subject.foo = value }

      it "must read the options value from @options" do
        expect(subject.instance_variable_get('@command_options')[:foo]).to be(value)
      end
    end

    context "when given a short flag" do
      context "and it's length is < 3" do
        module TestCommand
          class EmptyCommand < CommandMapper::Command
          end
        end

        let(:command_class) { TestCommand::EmptyCommand }

        it "must raise an ArgumentError" do
          expect {
            subject.option '-o'
          }.to raise_error(ArgumentError,"cannot infer a name from short option flag: \"-o\"")
        end
      end

      context "but it's length is >= 3" do
        module TestCommand
          class ShortOptionWithoutName < CommandMapper::Command
            option "-ip"
          end
        end

        let(:command_class) { TestCommand::ShortOptionWithoutName }

        it "must register an option based on the short flag" do
          expect(subject.options[:ip]).to be_kind_of(Option)
          expect(subject.options[:ip].name).to eq(:ip)
          expect(subject.options[:ip].flag).to eq("-ip")
        end

        it "must define a reader method for the option" do
          expect(subject.instance_methods(false)).to include(:ip)
        end

        it "must define a writter method for the option" do
          expect(subject.instance_methods(false)).to include(:ip=)
        end
      end
    end

    context "when the argument shares the same name as an internal method" do
      let(:command_class) { Class.new(described_class) }
      let(:flag) { "--flag"      }
      let(:name) { :command_argv }

      it do
        expect {
          command_class.option flag, name: name
        }.to raise_error(ArgumentError,"option #{flag.inspect} with name #{name.inspect} cannot override the internal method with same name: ##{name}")
      end
    end

    context "when the argument flag maps to an existing internal method" do
      let(:command_class) { Class.new(described_class) }
      let(:flag) { "--command-argv" }
      let(:name) { :command_argv    }

      it do
        expect {
          command_class.option(flag)
        }.to raise_error(ArgumentError,"option #{flag.inspect} maps to method name ##{name} and cannot override the internal method with same name: ##{name}")
      end
    end
  end

  describe ".arguments" do
    subject { command_class }

    context "when the command has no defined arguments" do
      let(:command_class) { TestCommand::EmptyCommand }

      it { expect(subject.arguments).to be_empty }
    end

    context "when the comand does have defined arguments" do
      module TestCommand
        class BaseClassWithOptions < CommandMapper::Command
          argument :foo
          argument :bar
        end

        class InheritedOptions < BaseClassWithOptions
        end
      end

      let(:command_class) { TestCommand::InheritedOptions }
      let(:command_superclass) { TestCommand::BaseClassWithOptions }

      it "must copy the arguments defined in the superclass" do
        expect(subject.arguments).to eq(command_superclass.arguments)
      end

      context "and when the class defines arguments of it's own" do
        module TestCommand
          class InheritsAndDefinesOptions < BaseClassWithOptions
            argument :baz
          end
        end

        let(:command_class) { TestCommand::InheritsAndDefinesOptions }

        it "must copy the arguments defined in the superclass" do
          expect(subject.arguments).to include(command_superclass.arguments)
        end

        it "must define it's own arguments" do
          expect(command_class.arguments[:baz]).to be_kind_of(Argument)
        end

        it "must not modify the superclass's arguments" do
          expect(command_superclass.arguments[:baz]).to be(nil)
        end
      end
    end
  end

  describe ".argument" do
    module TestCommand
      class DefinesArgument < CommandMapper::Command
        command 'test' do
          argument :foo
        end
      end
    end

    let(:command_class) { TestCommand::DefinesArgument }

    subject { command_class }

    it "must register an argument with the given name" do
      expect(subject.arguments[:foo]).to be_kind_of(Argument)
      expect(subject.arguments[:foo].name).to eq(:foo)
    end

    it "must define a reader method for the argument" do
      expect(subject.instance_methods(false)).to include(:foo)
    end

    it "must define a writter method for the argument" do
      expect(subject.instance_methods(false)).to include(:foo=)
    end

    describe "reader method" do
      subject { command_class.new }

      let(:value) { "test_reading" }

      before do
        subject.instance_variable_get("@command_arguments")[:foo] = value
      end

      it "must read the options value from @arguments" do
        expect(subject.foo).to be(value)
      end
    end

    describe "writter method" do
      subject { command_class.new }

      let(:value) { "test_writing" }

      before { subject.foo = value }

      it "must read the options value from @arguments" do
        expect(subject.instance_variable_get('@command_arguments')[:foo]).to be(value)
      end
    end

    context "when the argument shares the same name as an internal method" do
      let(:command_class) { Class.new(described_class) }
      let(:name) { :command_argv }

      it do
        expect {
          command_class.argument(name)
        }.to raise_error(ArgumentError,"argument #{name.inspect} cannot override internal method with same name: ##{name}")
      end
    end
  end

  describe ".subcommands" do
    subject { command_class }

    context "when the command has no defined subcommands" do
      let(:command_class) { TestCommand::EmptyCommand }

      it { expect(subject.subcommands).to be_empty }
    end

    context "when the comand does have defined subcommands" do
      module TestCommand
        class BaseClassWithOptions < CommandMapper::Command
          subcommand :foo do
          end

          subcommand :bar do
          end
        end

        class InheritedOptions < BaseClassWithOptions
        end
      end

      let(:command_class) { TestCommand::InheritedOptions }
      let(:command_superclass) { TestCommand::BaseClassWithOptions }

      it "must copy the subcommands defined in the superclass" do
        expect(subject.subcommands).to eq(command_superclass.subcommands)
      end

      context "and when the class defines subcommands of it's own" do
        module TestCommand
          class InheritsAndDefinesOptions < BaseClassWithOptions

            subcommand :baz do
            end

          end
        end

        let(:command_class) { TestCommand::InheritsAndDefinesOptions }

        it "must copy the subcommands defined in the superclass" do
          expect(subject.subcommands).to include(command_superclass.subcommands)
        end

        it "must define it's own subcommands" do
          expect(command_class.subcommands[:baz]).to eq(command_class::Baz)
        end

        it "must not modify the superclass's subcommands" do
          expect(command_superclass.subcommands[:baz]).to be(nil)
        end
      end
    end
  end

  describe ".subcommand" do
    module TestCommand
      class DefinesSubcommand < CommandMapper::Command
        subcommand "subcmd" do
          option '--foo'
          option '--bar'
          argument :baz
        end
      end
    end

    let(:command_class) { TestCommand::DefinesSubcommand }

    subject { command_class }

    it "must add the subcommand to .subcommands using the method name" do
      expect(subject.subcommands[:subcmd]).to be(command_class::Subcmd)
    end

    it "must define a constant for the new Subcommand class" do
      expect(subject.const_get('Subcmd')).to (be < described_class)
    end

    it "must initialize a new Command with the given subcommand name" do
      expect(subject.const_get('Subcmd').command_name).to eq("subcmd")
    end

    it "must define a reader method for the subcommand" do
      expect(subject.instance_methods(false)).to include(:subcmd)
    end

    it "must define a writter method for the subcommand" do
      expect(subject.instance_methods(false)).to include(:subcmd=)
    end

    context "when the subcommand name contains a '-'" do
      module TestCommand
        class DefinesSubcommand < CommandMapper::Command
          subcommand 'sub-cmd' do
            option '--foo'
            option '--bar'
            argument :baz
          end
        end
      end

      let(:command_class) { TestCommand::DefinesSubcommand }

      it "must add the subcommand to .subcommands using the method name" do
        expect(subject.subcommands[:sub_cmd]).to be(command_class::SubCmd)
      end

      it "must define a CamelCased subcommand constant" do
        expect(subject.const_get('SubCmd')).to (be < described_class)
      end

      it "must replace any '-' characters with '_' for the reader method" do
        expect(subject.instance_methods(false)).to include(:sub_cmd)
      end

      it "must replace any '-' characters with '_' for the writer method" do
        expect(subject.instance_methods(false)).to include(:sub_cmd=)
      end
    end

    context "when the subcommand shares the same name as an internal method" do
      let(:command_class) { Class.new(described_class) }
      let(:name)          { "command-argv" }
      let(:method_name)   { 'command_argv' }

      it do
        expect {
          command_class.subcommand(name) do
          end
        }.to raise_error(ArgumentError,"subcommand #{name.inspect} maps to method name ##{method_name} and cannot override the internal method with same name: ##{method_name}")
      end
    end
  end

  module TestCommand
    class ExampleCommand < CommandMapper::Command
      command 'test' do
        option '--opt1', value: {required: true}
        option '--opt2', value: {required: true}
        option '--opt3', value: {required: true}
        argument :arg1, value: {required: false}
        argument :arg2, value: {required: false}
        argument :arg3, value: {required: false}

        subcommand 'subcmd' do
          option '--sub-opt1', value: {required: true}
          argument :sub_arg1, value: {required: true}
        end
      end
    end
  end

  let(:opt1) { "foo" }
  let(:opt2) { "bar" }
  let(:opt3) { "baz" }
  let(:arg1) { "foo" }
  let(:arg2) { "bar" }
  let(:arg3) { "baz" }
  let(:env)  { {'FOO' => 'bar'} }

  let(:command_class) { TestCommand::ExampleCommand }

  describe "#initialize" do
    subject { command_class.new() }

    it "must default #command_name to self.class.command" do
      expect(subject.command_name).to eq(command_class.command_name)
    end

    it "must default #env to {}" do
      expect(subject.command_env).to eq({})
    end

    it "must default options to {}" do
      expect(subject.command_options).to eq({})
    end

    it "must default arguments to {}" do
      expect(subject.command_arguments).to eq({})
    end

    it "must default #command_subcommand to nil" do
      expect(subject.command_subcommand).to be(nil)
    end

    context "when initialized with a Hash of options and arguments" do
      let(:params) do
        {opt1: opt1, opt2: opt2, arg2: arg2, arg3: arg3}
      end

      subject { command_class.new(params) }

      it "must populate #options and #arguments" do
        expect(subject.command_options).to eq({opt1: opt1, opt2: opt2})
        expect(subject.command_arguments).to eq({arg2: arg2, arg3: arg3})
      end
    end

    context "when initialized with additional keywords" do
      let(:params) do
        {opt1: opt1, opt2: opt2, arg2: arg2, arg3: arg3}
      end

      subject { command_class.new(**params) }

      it "must populate #options and #arguments" do
        expect(subject.command_options).to eq({opt1: opt1, opt2: opt2})
        expect(subject.command_arguments).to eq({arg2: arg2, arg3: arg3})
      end
    end

    context "when initialized with command_name: ..." do
      let(:command_name) { 'foo2' }

      subject { command_class.new(command_name: command_name) }

      it "must override #command" do
        expect(subject.command_name).to eq(command_name)
      end
    end

    context "when initialized with command_path: ..." do
      let(:command_path) { '/path/to/foo' }

      subject { command_class.new(command_path: command_path) }

      it "must override #command" do
        expect(subject.command_path).to eq(command_path)
      end
    end

    context "when initialized with command_env: {...}" do
      subject { command_class.new(command_env: env) }

      it "must populate #env" do
        expect(subject.command_env).to eq(env)
      end
    end
  end

  describe "#[]" do
    let(:name)  { :opt1  }
    let(:value) { 'test' }

    subject { command_class.new(opt1: value) }

    it "must call the method with the same given name" do
      expect(subject).to receive(name).and_return(value)

      expect(subject[name]).to be(value)
    end

    context "when there is no reader method of the same name" do
      let(:name) { :fubar }

      it do
        expect {
          subject[name]
        }.to raise_error(ArgumentError,"#{command_class} does not define ##{name}")
      end
    end
  end

  describe "#[]=" do
    let(:name)  { :opt2  }
    let(:value) { 'new_value' }

    subject { command_class.new }

    it "must call the writter method with the same given name" do
      expect(subject).to receive(:"#{name}=").with(value).and_return(value)

      subject[name] = value
    end

    it "must return the new value" do
      expect(subject[name] = value).to be(value)
    end

    context "when there is no reader method of the same name" do
      let(:name) { :fubar }

      it do
        expect {
          subject[name] = value
        }.to raise_error(ArgumentError,"#{command_class} does not define ##{name}=")
      end
    end
  end

  describe "#command_argv" do
    context "when the command has no options or arguments set" do
      subject { command_class.new }

      it "must return an argv only containing the command name" do
        expect(subject.command_argv).to eq([subject.class.command_name])
      end

      context "but the command has required arguments" do
        module TestCommand
          class CommandWithRequiredArguments < CommandMapper::Command
            command "test" do
              option '--opt1', value: {required: true}
              option '--opt2', value: {required: true}
              option '--opt3', value: {required: true}
              argument :arg1, value: {required: false}
              argument :arg2, value: {required: true}
              argument :arg3, value: {required: false}
            end
          end
        end

        let(:command_class) { TestCommand::CommandWithRequiredArguments }

        it do
          expect {
            subject.command_argv
          }.to raise_error(ArgumentRequired,"argument arg2 is required")
        end
      end
    end

    context "when the command is initialized with the command_path: keyword" do
      let(:command_path) { '/path/to/foo' }

      subject { command_class.new(command_path: command_path) }

      it "must override the command name" do
        expect(subject.command_argv).to eq([subject.command_path])
      end
    end

    context "when the command has options set" do
      subject { command_class.new({opt1: opt1, opt2: opt2, opt3: opt3}) }

      it "must return an argv containing the command name and option flags followed by values" do
        expect(subject.command_argv).to eq(
          [
            subject.class.command_name,
            '--opt1', opt1,
            '--opt2', opt2,
            '--opt3', opt3
          ]
        )
      end
    end

    context "when the command has arguments set" do
      subject { command_class.new({arg1: arg1, arg2: arg2, arg3: arg3}) }

      it "must return an argv containing the command name and argument values" do
        expect(subject.command_argv).to eq(
          [subject.command_name, arg1, arg2, arg3]
        )
      end

      context "when the arguments are initialized in a different order" do
        subject { command_class.new({arg2: arg2, arg1: arg1, arg3: arg3}) }

        it "must return the argument values in the order the arguments were defined" do
          expect(subject.command_argv).to eq(
            [subject.command_name, arg1, arg2, arg3]
          )
        end
      end

      context "and when one of the argument values starts with a '-'" do
        let(:arg2) { "--bar" }

        it "must separate the arguments with a '--'" do
          expect(subject.command_argv).to eq(
            [subject.command_name, "--", arg1, arg2, arg3]
          )
        end
      end
    end

    context "when the command has both options and arguments set" do
      subject do
        command_class.new(
          {
            opt1: opt1, opt2: opt2, opt3: opt3,
            arg1: arg1, arg2: arg2, arg3: arg3
          }
        )
      end

      it "must return an argv containing the command name, options flags and values, then argument values" do
        expect(subject.command_argv).to eq(
          [
            subject.command_name,
            '--opt1', opt1,
            '--opt2', opt2,
            '--opt3', opt3,
            arg1, arg2, arg3
          ]
        )
      end
    end

    context "when the command has a subcommand set" do
      let(:sub_opt1) { 'foo' }
      let(:sub_arg1) { 'bar' }

      subject do
        command_class.new(
          {
            subcmd: {sub_opt1: sub_opt1, sub_arg1: sub_arg1}
          }
        )
      end

      it "must return an argv containing the command name, sub-command name, subcommand options and arguments" do
        expect(subject.command_argv).to eq(
          [
            subject.command_name,
            'subcmd', '--sub-opt1', sub_opt1, sub_arg1
          ]
        )
      end

      context "and when the command also has options set" do
        subject do
          command_class.new(
            {
              opt1: opt1, opt2: opt2, opt3: opt3,
              subcmd: {sub_opt1: sub_opt1, sub_arg1: sub_arg1}
            }
          )
        end

        it "must return an argv containing the command name, global options, sub-command name, subcommand options and arguments" do
          expect(subject.command_argv).to eq(
            [
              subject.command_name,
              '--opt1', opt1,
              '--opt2', opt2,
              '--opt3', opt3,
              'subcmd', '--sub-opt1', sub_opt1, sub_arg1
            ]
          )
        end
      end

      context "and when the command also has arguments set" do
        subject do
          command_class.new(
            {
              opt1: opt1, opt2: opt2, opt3: opt3,
              arg1: arg1, arg2: arg2, arg3: arg3,
              subcmd: {sub_opt1: sub_opt1, sub_arg1: sub_arg1}
            }
          )
        end

        it "must return an argv containing the sub-command's options and arguments, instead of the command's arguments" do
          expect(subject.command_argv).to eq(
            [
              subject.command_name,
              '--opt1', opt1,
              '--opt2', opt2,
              '--opt3', opt3,
              'subcmd', '--sub-opt1', sub_opt1, sub_arg1
            ]
          )
        end
      end
    end
  end

  describe "#command_string" do
    let(:opt1) { "foo bar" }
    let(:arg1) { "baz qux" }

    subject { command_class.new({opt1: opt1, arg1: arg1}) }

    let(:escaped_command) { Shellwords.shelljoin(subject.command_argv) }

    it "must escape the command option values and argument values" do
      expect(subject.command_string).to eq(escaped_command)
    end

    context "when initialized with command_env: {...}" do
      let(:env) { {"FOO" => "bar baz"} }

      let(:escaped_env) do
        env.map { |name,value|
          "#{Shellwords.shellescape(name)}=#{Shellwords.shellescape(value)}"
        }.join(' ')
      end

      let(:escaped_command) { Shellwords.shelljoin(subject.command_argv) }

      subject { command_class.new({opt1: opt1, arg1: arg1}, command_env: env) }

      it "must escape both the env variables and the command" do
        expect(subject.command_string).to eq(
          "#{escaped_env} #{escaped_command}"
        )
      end
    end
  end

  describe "#run_command" do
    subject { command_class.new({opt1: opt1, arg1: arg1}, command_env: env) }

    it "must pass the command's env and argv to Kenrel.system" do
      expect(subject).to receive(:system).with(env,*subject.command_argv)

      subject.run_command
    end
  end

  describe "#capture_command" do
    subject { command_class.new({opt1: opt1, arg1: arg1}, command_env: env) }

    it "must pass the command's env and argv to `...`" do
      expect(subject).to receive(:`).with(subject.command_string)

      subject.capture_command
    end
  end

  describe "#popen_command" do
    subject { command_class.new({opt1: opt1, arg1: arg1}, command_env: env) }

    it "must pass the command's env, argv, and to IO.popen" do
      expect(IO).to receive(:popen).with(env,subject.command_argv)

      subject.popen_command
    end

    context "when a open mode is given" do
      let(:mode) { 'w' }

      it "must pass the command's env, argv, and the mode to IO.popen" do
        expect(IO).to receive(:popen).with(env,subject.command_argv,mode)

        subject.popen_command(mode)
      end
    end
  end

  describe "#sudo!" do
    subject { command_class.new({opt1: opt1, arg1: arg1}, command_env: env) }

    let(:expected_argv) { [command_class.command, "--opt1", opt1, arg1] }

    it "must pass the command's env and argv, and to IO.popen" do
      expect(Sudo).to receive(:run).with({command: subject.command_argv}, command_env: env)

      subject.sudo_command
    end
  end

  describe "#to_s" do
    let(:opt1) { "foo bar" }
    let(:arg1) { "baz qux" }
    let(:env) { {"FOO" => "bar baz"} }

    subject { command_class.new({opt1: opt1, arg1: arg1}, command_env: env) }

    it "must call #command_string" do
      expect(subject.to_s).to eq(subject.command_string)
    end
  end

  describe "#to_a" do
    subject { command_class.new({opt1: opt1, arg1: arg1}) }

    it "must call #command_argv" do
      expect(subject.to_a).to eq(subject.command_argv)
    end
  end
end

require 'spec_helper'
require 'command_mapper/command'

describe CommandMapper::Command do
  describe ".command_name" do
    subject { command_class }

    context "when a .command_name has been defined" do
      module TestCommand
        class WithCommandName < CommandMapper::Command
          command 'foo'
        end
      end

      let(:command_class) { TestCommand::WithCommandName }

      it "must return the defined command name" do
        expect(subject.command).to eq('foo')
      end

      it "must freeze the given command name" do
        expect(subject.command).to be_frozen
      end
    end

    context "when no .command has been defined" do
      module TestCommand
        class NoCommandName < CommandMapper::Command
        end
      end

      let(:command_class) { TestCommand::NoCommandName }

      it "must raise NotImplementedError" do
        expect {
          subject.command
        }.to raise_error(NotImplementedError,"#{command_class} did not set command")
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
        command 'test'
        option '--foo'
        option '--bar'
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

      before { subject.instance_variable_get("@options")[:foo] = value }

      it "must read the options value from @options" do
        expect(subject.foo).to be(value)
      end
    end

    describe "writter method" do
      subject { command_class.new }

      let(:value) { "test_writing" }

      before { subject.foo = value }

      it "must read the options value from @options" do
        expect(subject.instance_variable_get('@options')[:foo]).to be(value)
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
        command 'test'
        argument :foo
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

      before { subject.instance_variable_get("@arguments")[:foo] = value }

      it "must read the options value from @arguments" do
        expect(subject.foo).to be(value)
      end
    end

    describe "writter method" do
      subject { command_class.new }

      let(:value) { "test_writing" }

      before { subject.foo = value }

      it "must read the options value from @arguments" do
        expect(subject.instance_variable_get('@arguments')[:foo]).to be(value)
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

    it "must define a constant for the new Subcommand class" do
      expect(subject.const_get('Subcmd')).to (be < described_class)
    end

    it "must initialize a new Command with the given subcommand name" do
      expect(subject.const_get('Subcmd').command).to eq("subcmd")
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
  end

  module TestCommand
    class ExampleCommand < CommandMapper::Command
      command 'test'
      option '--opt1', value: {required: true}
      option '--opt2', value: {required: true}
      option '--opt3', value: {required: true}
      argument :arg1, value: {required: true}
      argument :arg2, value: {required: true}
      argument :arg3, value: {required: true}

      subcommand :subcmd do
        option '--sub-opt1', value: {required: true}
        argument :sub_arg1, value: {required: true}
      end
    end
  end

  let(:command_class) { TestCommand::ExampleCommand }

  describe "#[]" do
    let(:name)  { :opt1  }
    let(:value) { 'test' }

    subject { command_class.new({opt1: value}) }

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

  describe "#argv" do
    context "when the command has no options or arguments set" do
      subject { command_class.new }

      it "must return an argv only containing the command name" do
        expect(subject.argv).to eq([subject.class.command])
      end
    end

    let(:opt1) { "foo" }
    let(:opt2) { "bar" }
    let(:opt3) { "baz" }

    context "when the command has options set" do
      subject { command_class.new({opt1: opt1, opt2: opt2, opt3: opt3}) }

      it "must return an argv containing the command name and option flags followed by values" do
        expect(subject.argv).to eq(
          [
            subject.class.command,
            '--opt1', opt1,
            '--opt2', opt2,
            '--opt3', opt3
          ]
        )
      end
    end

    let(:arg1) { "foo" }
    let(:arg2) { "bar" }
    let(:arg3) { "baz" }

    context "when the command has arguments set" do
      subject { command_class.new({arg1: arg1, arg2: arg2, arg3: arg3}) }

      it "must return an argv containing the command name and argument values" do
        expect(subject.argv).to eq(
          [subject.class.command, arg1, arg2, arg3]
        )
      end

      context "and when one of the argument values starts with a '-'" do
        let(:arg2) { "--bar" }

        it "must separate the arguments with a '--'" do
          expect(subject.argv).to eq(
            [subject.class.command, "--", arg1, arg2, arg3]
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
        expect(subject.argv).to eq(
          [
            subject.class.command,
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
        expect(subject.argv).to eq(
          [
            subject.class.command,
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
          expect(subject.argv).to eq(
            [
              subject.class.command,
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
          expect(subject.argv).to eq(
            [
              subject.class.command,
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
end

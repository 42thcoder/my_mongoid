require 'spec_helper'

class ATM
  include MyMongoid::Document

  field :a
end

def config_db
  MyMongoid.configure do |config|
    config.host = "127.0.0.1:27017"
    config.database = "my_mongoid_test"
  end
end

describe "Should define lifecycle callbacks" do
  describe "before, around, after hooks" do

    before(:all) do
      class ATM
        def do_something
        end

        def do_something_around
          # something before
          yield
          # something after
        end
      end
    end
    it "should declare before hook for delete" do
      expect {
        ATM.send(:before_delete, :do_something)
      }.not_to raise_error
    end

    it "should declare around hook for delete" do
      expect {
        ATM.send(:around_delete, :do_something_around)
      }.not_to raise_error
    end

    it "should declare after hook for delete" do
      expect {
        ATM.send(:after_delete, :do_something)
      }.not_to raise_error
    end

    it "should declare before hook for save" do
      expect {
        ATM.send(:before_save, :do_something)
      }.not_to raise_error
    end

    it "should declare around hook for save" do
      expect {
        ATM.send(:around_save, :do_something_around)
      }.not_to raise_error
    end

    it "should declare after hook for save" do
      expect {
        ATM.send(:after_save, :do_something)
      }.not_to raise_error
    end

    it "should declare before hook for create" do
      expect {
        ATM.send(:before_create, :do_something)
      }.not_to raise_error
    end

    it "should declare around hook for create" do
      expect {
        ATM.send(:around_create, :do_something_around)
      }.not_to raise_error
    end

    it "should declare after hook for create" do
      expect {
        ATM.send(:after_create, :do_something)
      }.not_to raise_error
    end

    it "should declare before hook for update" do
      expect {
        ATM.send(:before_update, :do_something)
      }.not_to raise_error
    end

    it "should declare around hook for update" do
      expect {
        ATM.send(:around_update, :do_something_around)
      }.not_to raise_error
    end

    it "should declare after hook for update" do
      expect {
        ATM.send(:after_update, :do_something)
      }.not_to raise_error
    end
  end

  describe "only after hooks" do

    before(:all) do
      class ATM
        def do_something
        end

        def do_something_around
          # something before
          yield
          # something after
        end
      end
    end

    it "should not declare before hook for find" do
      expect {
        ATM.send(:before_find, :do_something)
      }.to raise_error
    end

    it "should not declare around for find" do
      expect {
        ATM.send(:around_find, :do_something_around)
      }.to raise_error
    end

    it "should declare after hook for find" do
      expect {
        ATM.send(:after_find, :do_something)
      }.not_to raise_error
    end

    it "should not declare before hook for initialize" do
      expect {
        ATM.send(:before_initialize, :do_something)
      }.to raise_error
    end

    it "should not declare around for initialize" do
      expect {
        ATM.send(:around_initialize, :do_something_around)
      }.to raise_error
    end

    it "should declare after hook for initialize" do
      expect {
        ATM.send(:after_initialize, :do_something)
      }.not_to raise_error
    end

  end

  describe "create callbacks" do

    before(:all) do
      config_db
      class ATM
        def gotcha
        end

        def got_again
        end
      end
    end

    let(:atm) {
      ATM.new({ :a => "omg" })
    }

    it "should run callbacks when saving a new record" do
      ATM.send(:before_save, :gotcha)
      expect(atm).to receive(:gotcha)
      atm.save
    end

    it "should run callbacks wehn creating a new record" do
      ATM.send(:before_save, :got_again)
      expect_any_instance_of(ATM).to receive(:got_again)
      ATM.create({ :a => "yeah" })
    end
  end

  describe "run save callbacks" do
    before(:all) do
      config_db
      class ATM
        def save_callback
        end
      end
    end

    let(:atm) {
      ATM.create({ :a => "yes" })
    }

    it "should run callbacks when saving a new record" do
      # duplicated with the one above
    end

    it "should run callbacks when saving a persisted record" do
      ATM.send(:after_save, :save_callback)
      expect(atm).not_to be_new_record
      expect(atm).to receive(:save_callback)
      atm.a = "bye"
      atm.save
    end
  end

end

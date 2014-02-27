require "spec_helper"

# todo

class Event
  include MyMongoid::Document
  field :public
end
describe "Document modules:" do
  it "creates MyMongoid::Document" do
    expect(MyMongoid::Document).to be_a(Module)
  end

  it "creates MyMongoid::Document::ClassMethods" do
    expect(MyMongoid::Document::ClassMethods).to be_a(Module)
  end
end

describe "Create a model:" do
  describe Event do
    it "is a mongoid model" do
      expect(Event.is_mongoid_model?).to eq(true)
    end
  end

  describe MyMongoid do
    it "maintains a list of models" do
      expect(MyMongoid.models).to include(Event)
    end
  end
end

describe "Instantiate a model:" do
  let(:attributes) {
    {"_id" => "123", "public" => true}
  }

  let(:event) {
    Event.new(attributes)
  }

  it "can instantiate a model with attributes" do
    expect(event).to be_an(Event)
  end

  it "throws an error if attributes it not a Hash" do
    expect {
      Event.new(100)
    }.to raise_error(ArgumentError)
  end

  it "can read the attributes of model" do
    expect(event.attributes).to eq(attributes)
  end

  it "can get an attribute with #read_attribute" do
    expect(event.read_attribute("_id")).to eq("123")
  end

  it "can set an attribute with #write_attribute" do
    event.write_attribute("id","234")
    expect(event.read_attribute("id")).to eq("234")
  end

  it "is a new record initially" do
    expect(event).to be_new_record
  end
end

describe "Should track changes made to a record" do
  class AB
    include MyMongoid::Document
    field :a
    field :b
  end
  let(:event) {
    AB.instantiate({"a" => 1, "b" => 2})
  }

  describe "#changed_attributes" do


    it "should be an empty hash for an newly instantiated record (from Model.instantiate)" do
      expect(event.changed_attributes).to eq({})
    end

    it "should track writes to attributes" do
      event.a = 10
      event.write_attribute("b",20)
      expect(event.changed_attributes.keys).to include("a","b")
    end

    it "should keep the original attribute values" do
      event.a = 10
      expect(event.changed_attributes["a"]).to eq(1)
      event.write_attribute("b",20)
      expect(event.changed_attributes["b"]).to eq(2)
    end

    it "should not make a field dirty if the assigned value is equaled to the old value" do
      event.a = 1
      expect(event.changed_attributes).to be_empty
    end
  end

  describe "#changed?" do
    it "should be false for a newly instantiated record" do
      expect(event).to_not be_changed
    end

    it "should be true if a field changed" do
      event.a = 20
      expect(event).to be_changed
    end
  end
end

describe "Should be able to update a record:" do

  before {
    config_db
    AnotherEvent.collection.drop
  }

  describe "#atomic_updates" do
    let(:event) {
      AB.instantiate({"a" => 1, "b" => 2})
    }

    it "should return {} if nothing changed" do
      expect(event.atomic_updates).to be_empty
    end

    it "should return {} if record is not a persisted document" do
      event = AB.new({"a" => 1})
      expect(event.atomic_updates).to be_empty
    end

    it "should generate the $set update operation to update a persisted document" do
      event.a = 10
      event.b = 20
      set = event.atomic_updates["$set"]
      expect(set).to be_an(Hash)
      expect(set).to eq({"a" => 10, "b" => 20})
    end
  end

  describe "updating database:" do
    before(:all) { config_db }
    before { AB.collection.drop }
    let(:attrs) {
      {"_id" => "1", "a" => 1, "b" => 2}
    }

    let(:event) {
      AB.create(attrs)
    }

    let(:event2) {
      AB.find("1")
    }

    describe "#save" do
      it "should have no changes right after persisting" do
        expect(event).to_not be_changed
      end
    end

    describe "#update_document" do
      it "should not issue query if nothing changed" do
        expect_any_instance_of(Moped::Query).to_not receive(:update)
        event.update_document
        expect(event2.attributes).to eq(attrs)
      end

      it "should update the document in database if there are changes" do
        event.a = 10
        event.update_document
        expect(event2.a).to eq(10)
      end
    end

    describe "#save" do
      it "should save the changes if a document is already persisted" do
        event.a = 10
        event.save
        expect(event2.a).to eq(10)
      end
    end

    describe "#update_attributes" do
      it "should change and persiste attributes of a record" do
        event.update_attributes "a" => 10, "b" => 20
        expect(event2.a).to eq(10)
        expect(event2.b).to eq(20)
      end
    end
  end
end

describe "Should be able to delete a record:" do
  let(:attrs) {
    {"_id" => "1", "a" => 1, "b" => 2}
  }

  let(:event) {
    AB.find("1")
  }

  before {
    config_db
    AB.collection.drop
    AB.create(attrs)
  }

  describe "#delete" do
    before {
      event.delete
    }
    it "should delete a record from db" do
      expect {
        AB.find("1")
      }.to raise_error(MyMongoid::RecordNotFoundError)
    end

    it "should return true for deleted?" do
      expect(event).to be_deleted
    end
  end

end

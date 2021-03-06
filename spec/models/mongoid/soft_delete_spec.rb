require 'rails_helper'

class WalkingDead
  include Mongoid::Document
  include Mongoid::BaseModel
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  include Mongoid::SoftDelete

  field :name
  field :tag

  after_destroy do
    self.tag = "after_destroy #{name}"
  end
end

describe 'Soft Delete', type: :model do
  let!(:rick) { WalkingDead.create! name: 'Rick Grimes' }

  it 'should affect default count' do
    expect do
      rick.destroy
    end.to change(WalkingDead, :count).by(-1)
  end

  it 'should not affect unscoped count' do
    expect do
      rick.destroy
    end.to_not change(WalkingDead.unscoped, :count)
  end

  it 'should update the deleted_at field' do
    expect do
      rick.destroy
    end.to change { rick.deleted_at }.from(nil)
  end

  it 'should use deleted?' do
    expect do
      rick.destroy
    end.to change { rick.deleted? }.from(false).to(true)
  end

  it 'should mark as destroyed and get proper query result' do
    rick.destroy
    expect(rick).to be_destroyed

    expect(WalkingDead.where(name: rick.name).count).to eq(0)
    expect(WalkingDead.unscoped.where(name: rick.name).first).to eq(rick)
  end

  it 'is run callback after destroy' do
    rick.name = 'foo'
    rick.destroy
    expect(rick.tag).to eq('after_destroy foo')
  end
end

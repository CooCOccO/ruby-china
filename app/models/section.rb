class Section
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  field :name
  field :sort, type: Integer, default: 0
  has_many :nodes, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  default_scope -> { desc(:sort) }

  after_save :update_cache_version
  after_destroy :update_cache_version

  def update_cache_version
    # 记录节点变更时间，用于清除缓存
    CacheVersion.section_node_updated_at = Time.now.to_i
  end

  def sorted_nodes
    nodes.where(:_id.nin => [Node.no_point_id]).sorted
  end
end

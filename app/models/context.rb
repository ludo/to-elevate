class Context
  include DataMapper::Resource

  # === Properties
  property :id, Serial
  property :name, String, :size => 32, :nullable => false
  property :active, Boolean, :nullable => false, :default => true
  
  # === Associations
  belongs_to :user
  has n, :tasks

  # === Validations
  validates_is_unique :name, :scope => [:user]

  # === Instance methods

  # Toggle the state of a context
  #
  # --
  # @api public
  def toggle
    attribute_set(:active, !active)
  end
  
  # Return the name when stringified
  #
  # ===== Returns
  # String:: The context's name
  #
  # --
  # @api public
  def to_s
    name
  end
  
  # === Class methods
  class << self
    
    # Find all active contexts
    #
    # ==== Returns
    # Array<Context>:: All active contexts
    def find_active
      self.all(:active => true, :order => [:name])
    end
    
    # Find all hidden contexts
    #
    # ==== Returns
    # Array<Context>:: All hidden contexts
    def find_hidden
      self.all(:active => false, :order => [:name])
    end
    
  end
end

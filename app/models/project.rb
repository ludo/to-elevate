class Project
  include DataMapper::Resource

  # === Properties
  property :id, Serial
  property :title, String, :size => 64, :nullable => false
  property :outcome, String, :size => 256
  property :someday, Boolean, :default => false, :nullable => false
  property :created_at, DateTime
  property :updated_at, DateTime
  property :completed_at, DateTime
  property :user_id, Integer, :nullable => false
  
  # === Associations
  belongs_to :user
  has n, :tasks

  # === Instance methods
  
  # Find out whether this project is completed or not
  #
  # ==== Returns
  # Boolean:: True when project is marked completed
  #
  # -
  # @api public
  def completed?
    completed_at ? true : false
  end

  def count_uncompleted_tasks
    tasks.count(:completed_at => nil) || 0
  end
  
  # Toggle the state of a project
  #
  # * When a project is not yet completed (<tt>completed_at</tt> is <tt>nil</tt>),
  #   then <tt>completed_at</tt> will be populated with the current timestamp.
  # * When a project is already marked as completed (<tt>completed_at</tt> is not
  #   <tt>nil</tt>) then <tt>completed_at</tt> will be reset to <tt>nil</tt>.
  #
  # -
  # @api public
  def toggle
    if completed_at
      attribute_set(:completed_at, nil)
    else
      attribute_set(:completed_at, DateTime.now) # TODO look into timezone support
    end
  end
  
  # Return the title when stringified
  #
  # ===== Returns
  # String:: The project's title
  #
  # -
  # @api public
  def to_s
    title
  end
  
  # === Class methods
  class << self
    
    # Find all active projects
    #
    # ==== Returns
    # Array<Project>:: All active projects
    def find_active
      self.all(
        :completed_at => nil, 
        :someday => false,
        :order => [:title])
    end
    
    # Find all someday/maybe projects
    #
    # ==== Returns
    # Array<Project>:: All someday/maybe projects
    def find_someday
      self.all(
        :completed_at => nil, 
        :someday => true,
        :order => [:title])
    end
    
    # Find all completed projects
    #
    # This includes both completed 'someday/maybe' projects as well as 
    # completed 'normal' projects.
    #
    # ==== Returns
    # Array<Project>:: All completed projects
    def find_completed
      self.all(
        :completed_at.not => nil, 
        :order => [:title])
    end
  end
end

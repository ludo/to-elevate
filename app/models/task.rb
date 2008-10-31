class Task
  include DataMapper::Resource

  # === Properties
  property :id, Serial
  property :title, String, :size => 64, :nullable => false
  property :notes, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  property :due_on, Date, :nullable => true
  property :completed_at, DateTime
  property :context_id, Integer, :nullable => false
  property :project_id, Integer
  property :user_id, Integer, :nullable => false
  
  # === Associations
  belongs_to :context
  belongs_to :project
  belongs_to :user

  # === Instance methods
  
  # Find out whether this task is completed or not
  #
  # ==== Returns
  # Boolean:: True when task is marked completed
  def completed?
    completed_at ? true : false
  end
  
  # Set due_on date
  #
  # Verify whether <tt>value</tt> is a <tt>Date</tt>. If this is not the case then
  # <tt>value</tt> will be set to <tt>nil</tt>.
  #
  # ==== Paramaters
  # value<String>:: Date on which this task should be completed
  #
  # --
  # @api public
  def due_on=(value)
    value = nil if value.instance_of?(String) && value.length == 0
    attribute_set(:due_on, value)
  end
  
  def notes?
    notes && notes.length > 0 ? true : false
  end
  
  # Return the title when stringified
  #
  # ===== Returns
  # String:: The project's title
  def to_s
    title
  end
  
  # Toggle the state of a task
  #
  # * When a task is not yet completed (<tt>completed_at</tt> is <tt>nil</tt>),
  #   then <tt>completed_at</tt> will be populated with the current timestamp.
  # * When a task is already marked as completed (<tt>completed_at</tt> is not
  #   <tt>nil</tt>) then <tt>completed_at</tt> will be reset to <tt>nil</tt>.
  #
  # --
  # @api public
  def toggle
    if completed_at
      attribute_set(:completed_at, nil)
    else
      attribute_set(:completed_at, DateTime.now) # TODO look into timezone support
    end
  end
  
  # === Class methods
  class << self
    
    # Find active tasks
    #
    # ==== Parameters
    # conditions<Hash>:: Additional conditions
    #
    # ==== Returns
    # Array<Task>:: Active tasks
    def find_active(conditions = {})
      self.all({
        :completed_at => nil, 
        :order => [:due_on.desc, :created_at.asc]
      }.merge(conditions))
    end
    
    # Find completed tasks
    #
    # ==== Parameters
    # conditions<Hash>:: Additional conditions
    #
    # ==== Returns
    # Array<Task>:: Completed tasks
    def find_completed(conditions = {})
      self.all({
        :completed_at.not => nil, 
        :order => [:completed_at.desc]
      }.merge(conditions))
    end
  end
end

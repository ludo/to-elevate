class Tasks < Application
  # provides :xml, :yaml, :js

  before :ensure_authenticated

  # The Dashboard
  #
  # GET /tasks
  #
  # Displays contexts with active actions and displays the five most recently
  # completed actions.
  #
  # --
  # @api public
  def index
    only_provides :html

    # Next tasks grouped by context:
    # Retrieve all contexts that have at least one active task.
    @context_ids_to_show = repository(:default).adapter.query(%Q{
      select distinct context_id 
      from tasks 
      where completed_at is null 
      and context_id is not null
      and user_id = ?
    }, session.user.id)

    if @context_ids_to_show.size > 0
      @contexts = session.user.contexts.all(
        :id => @context_ids_to_show,
        :active => true,
        :order => [:name.asc]
      )
    else
      @contexts = []
    end
    
    display @contexts
  end

  # List completed tasks.
  #
  # GET /tasks/archive
  #
  # --
  # @api public
  def archive
    @completed_task_count = session.user.tasks.count(
      :completed_at.not => nil, 
      :order => [:completed_at.desc]
    ) || 0
    
    # Determine oldest completed task
    task = session.user.tasks.first(
      :completed_at.not => nil, 
      :order => [:completed_at]
    )
    
    # Create an array with years/months that have tasks
    @months = {}

    if task
      start_year = task.completed_at.year 
    
      for year in start_year..Date.today.year do 
        if year == start_year
          months = task.completed_at.month..12
        elsif year == Date.today.year
          months = 1..Date.today.month
        else
          months = 1..12
        end
      
        @months[year] = months.to_a.reverse
      end
    end
      
    render
  end
  
  def month
    @date = Date.parse(params[:date])
    @tasks = session.user.tasks.all(
      :completed_at.gte => @date, 
      :completed_at.lt => (@date >> 1),
      :order => [:completed_at.desc]
    )
    display @tasks
  end
  
  # Toggle a task
  def toggle
    only_provides :js
    @task = session.user.tasks.get(params[:id])
    raise NotFound unless @task
    @task.toggle
    @task.save
    
    # Where should this task go on the page?
    if @task.completed?
      @destination = "completed"
    else
      if request.referer.include?("/projects/")
        @destination = @task.project.title.to_slug
      else
        @destination = @task.context.name.to_slug
      end
    end
    
    render
  end

  def new
    only_provides :html
    @task = Task.new
    display @task
  end

  def edit(id)
    only_provides :html
    @task = session.user.tasks.get(id)
    raise NotFound unless @task
    display @task
  end

  def create(task)
    @task = Task.new(task.merge(:user_id => session.user.id))
    if @task.save
      redirect resource(:tasks), :message => {:notice => "Action was successfully created"}
    else
      message[:error] = "Action failed to be created"
      render :new
    end
  end

  def update(id, task)
    @task = session.user.tasks.get(id)
    raise NotFound unless @task
    if @task.update_attributes(task)
       redirect resource(:tasks), :message => {:notice => "Action was successfully updated"}
    else
      display @task, :edit
    end
  end

  def destroy(id)
    @task = session.user.tasks.get(id)
    raise NotFound unless @task
    if @task.destroy
      redirect resource(:tasks), :message => {:notice => "Action was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Tasks

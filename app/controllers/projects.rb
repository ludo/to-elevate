class Projects < Application
  # provides :xml, :yaml, :js

  before :ensure_authenticated

  def index
    @active_projects = session.user.projects.find_active
    @someday_projects = session.user.projects.find_someday
    @completed_projects = session.user.projects.find_completed
      
    display @active_projects
  end

  # Toggle a project
  #
  # -
  # @api public
  def toggle
    only_provides :js
    @project = session.user.projects.get(params[:id])
    raise NotFound unless @project
    @project.toggle
    @project.save
    
    # Where should this project go on the page?
    @destination = if !@project.completed? && @project.someday
      "someday"
    elsif @project.completed?
      "completed"
    else
      "active"
    end
    
    render
  end
  
  def show(id)
    @project = session.user.projects.get(id)
    raise NotFound unless @project
    display @project
  end

  def new
    only_provides :html
    @project = Project.new
    display @project
  end

  def edit(id)
    only_provides :html
    @project = session.user.projects.get(id)
    raise NotFound unless @project
    display @project
  end

  def create(project)
    @project = Project.new(project.merge(:user_id => session.user.id))
    if @project.save
      redirect resource(@project), :message => {:notice => "Project was successfully created"}
    else
      message[:error] = "Project failed to be created"
      render :new
    end
  end

  def update(id, project)
    @project = session.user.projects.get(id)
    raise NotFound unless @project
    if @project.update_attributes(project)
       redirect resource(@project)
    else
      display @project, :edit
    end
  end

  def destroy(id)
    @project = session.user.projects.get(id)
    raise NotFound unless @project
    if @project.destroy
      redirect resource(:projects)
    else
      raise InternalServerError
    end
  end

end # Projects

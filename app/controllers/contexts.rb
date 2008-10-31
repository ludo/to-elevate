class Contexts < Application
  # provides :xml, :yaml, :js

  before :ensure_authenticated
    
  def index
    @active_contexts = session.user.contexts.find_active
    @hidden_contexts = session.user.contexts.find_hidden
    
    display @active_contexts
  end

  # Toggle a context
  def toggle(id)
    only_provides :js
    @context = session.user.contexts.get(id)
    raise NotFound unless @context
    @context.toggle
    @context.save
    
    # Where should this context go on the page?
    @destination = @context.active? ? "active" : "completed"
    render
  end
  
  def show(id)
    @context = session.user.contexts.get(id)
    raise NotFound unless @context
    display @context
  end

  def new
    only_provides :html
    @context = Context.new
    display @context
  end

  def edit(id)
    only_provides :html
    @context = session.user.contexts.get(id)
    raise NotFound unless @context
    display @context
  end

  def create(context)
    @context = Context.new(context.merge(:user_id => session.user.id))
    if @context.save
      redirect resource(@context), :message => {:notice => "Context was successfully created"}
    else
      message[:error] = "Context failed to be created"
      render :new
    end
  end

  def update(id, context)
    @context = session.user.contexts.get(id)
    raise NotFound unless @context
    if @context.update_attributes(context)
      redirect resource(@context), :message => {:notice => "Context was successfully updated"}
    else
      display @context, :edit
    end
  end

  def destroy(id)
    @context = session.user.contexts.get(id)
    raise NotFound unless @context
    if @context.destroy
      redirect resource(:contexts), :message => {:notice => "Context was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Contexts

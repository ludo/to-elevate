module Merb
  module GlobalHelpers
    # Retrieve the number of active tasks
    #
    # TODO Do not include tasks that in hidden contexts.
    #
    # ==== Returns
    # FixNum:: Number of active tasks
    #
    # -
    # @api public
    def active_task_count
      session.user.tasks.count(:completed_at => nil) || 0
    end
    
    # Determine how to display due_on date for a task
    #
    # ==== Paramaters
    # task<Task>:: A Task
    #
    # ==== Returns
    # String:: HTML snippet containing information on tasks due date.
    #
    # -
    # @api public
    def due(task)
      if !task.completed? && task.due_on
        days = task.due_on - Date.today
        
        css_class = if days > 10
          "due"
        elsif days > 5
          "due_soon"
        else
          "due_alarm"
        end
        
        content = if days == 0
          "Due today"
        elsif days < 0
          days *= -1
          "Overdue #{days} #{days == 1 ? "day" : "days"}"
        else
          "Due in #{days} #{days == 1 ? "day" : "days"}"
        end
        
        tag :small, content, :class => css_class
      end
    end
    
    # Display a Gravatar avatar
    #
    # TODO Allow options, like different sizes
    #
    # ==== Parameters
    # email<String>:: E-mail address to show Gravatar for
    #
    # ==== Returns
    # String:: An URL to a Gravatar
    def gravatar(email)
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}.jpg?s=40"
    end
    
    # Little helper for selecting which menu will be active
    #
    # ==== Parameters
    # selected<Symbol>:: Name of the active menu
    #
    # -
    # @api public
    def menu(selected)
      @menu = selected
    end

    # Return user to previous page
    #
    # TODO Find way to remove hard-coded server uri
    #
    # ==== Returns
    # String:: Referer
    #
    # -
    # @api public
    def redirect_back
      if request.referer && request.referer.include?("http://#{request.host}")
        request.referer
      else
        url(:root)
      end
    end
    
    def render_menu
      menu = ""
      menu_items.sort { |a,b| a[1][:position] <=> b[1][:position] }.each do |item|
        # Set the active menu
        if item[0] == @menu
          item[1][:attrs] ||= {}
          item[1][:attrs][:class] = "#{item[1][:attrs][:class]} active"
        end

        # Create a tag for each item
      	menu += tag :li, item[1][:content], item[1][:attrs]
    	end
    	tag :ul, menu
    end
    
    # Set the <title> for a page
    #
    # --
    # @api public
    def title(value)
      throw_content(:for_title, "#{h(value)} - ")
    end
    
    # Creates a togglable checkbox field
    #
    # ==== Returns
    # String:: HTML checkbox input tag
    #
    # --
    # @api public
    def toggle_field(attrs = {})
      if attrs.has_key?(:checked)
        if attrs[:checked]
          attrs[:checked] = "checked"
        else
          attrs.delete(:checked)
        end
      end
      
      check_box(attrs)
    end
    
  private
  
    # Collection of menu items
    #
    # ==== Returns
    # Hash:: Hash containing menu items
    def menu_items
      {
        :dashboard => {
          :content => "#{link_to "Dashboard", url(:root)} [#{active_task_count}]",
          :position => 1
        },
        :projects => {
          :content => link_to("Projects", url(:projects)),
          :position => 2
        },
        :contexts => {
          :content => link_to("Contexts", url(:contexts)),
          :position => 3
        },
        :new_action => {
          :content => "+ #{link_to("Action", url(:new_task))}",
          :position => 4,
          :attrs => { :class => "right" }
        }
      }
    end
  end
end

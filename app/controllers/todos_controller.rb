class TodosController < ApplicationController
  before_action :set_todo, only: [:show, :edit, :update, :destroy, :toggle]
  
  # GET /todos
  def index
    @todos = filter_todos
    @stats = calculate_stats
    @pending_todos = @todos.pending.by_priority
    @completed_todos = @todos.completed.order(updated_at: :desc)
  end
  
  # GET /todos/1
  def show
  end
  
  # GET /todos/new
  def new
    @todo = Todo.new
  end
  
  # GET /todos/1/edit
  def edit
  end
  
  # POST /todos
  def create
    @todo = Todo.new(todo_params)
    result = TodoService.new(todo_params).create_todo
    
    handle_service_result(result, todos_path) do |todo|
      redirect_to todos_path, notice: 'Todo was successfully created.'
    end
  rescue => e
    # Fallback in case of any errors
    @todo ||= Todo.new(todo_params)
    render :new
  end
  
  # PATCH/PUT /todos/1
  def update
    result = TodoService.new.update_todo(@todo, todo_params)
    
    handle_service_result(result, todos_path) do |todo|
      redirect_to todos_path, notice: 'Todo was successfully updated.'
    end
  end
  
  # DELETE /todos/1
  def destroy
    @todo.destroy
    redirect_to todos_path, notice: 'Todo was successfully deleted.'
  end
  
  # PATCH /todos/1/toggle
  def toggle
    result = TodoService.new.toggle_completion(@todo)
    
    if result.success?
      redirect_to todos_path, notice: 'Todo status updated.'
    else
      redirect_to todos_path, alert: 'Failed to update todo status.'
    end
  end
  
  # POST /todos/bulk_action
  def bulk_action
    todo_ids = params[:todo_ids]&.reject(&:blank?)
    
    if todo_ids.blank?
      redirect_to todos_path, alert: 'Please select at least one todo.'
      return
    end
    
    result = case params[:bulk_action_type]
             when 'complete'
               TodoService.new.bulk_complete(todo_ids)
             when 'delete'
               TodoService.new.bulk_delete(todo_ids)
             else
               TodoService::Result.failure('Invalid action')
             end
    
    if result.success?
      redirect_to todos_path, notice: result.data[:message]
    else
      redirect_to todos_path, alert: result.errors
    end
  end
  
  private
  
  def set_todo
    @todo = Todo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to todos_path, alert: 'Todo not found.'
  end
  
  def todo_params
    params.require(:todo).permit(:title, :description, :priority, :due_date)
  end
  
  def filter_todos
    todos = Todo.all
    
    case params[:filter]
    when 'completed'
      todos = todos.completed
    when 'pending'
      todos = todos.pending
    when 'overdue'
      todos = todos.overdue
    when 'due_soon'
      todos = todos.due_soon
    when 'high_priority'
      todos = todos.where(priority: ['high', 'urgent'])
    end
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      todos = todos.where('LOWER(title) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?)', search_term, search_term)
    end
    
    todos
  end
  
  def calculate_stats
    {
      total: Todo.count,
      completed: Todo.completed.count,
      pending: Todo.pending.count,
      overdue: Todo.overdue.count,
      due_soon: Todo.due_soon.count
    }
  end
end

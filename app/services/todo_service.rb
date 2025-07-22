class TodoService < ApplicationService
  def initialize(params = {})
    @params = params
  end
  
  def create_todo
    todo = Todo.new(@params)
    
    if todo.save
      Result.success(todo)
    else
      Result.failure(todo.errors)
    end
  end
  
  def update_todo(todo, params)
    if todo.update(params)
      Result.success(todo)
    else
      Result.failure(todo.errors)
    end
  end
  
  def toggle_completion(todo)
    todo.toggle_completion!
    Result.success(todo)
  rescue ActiveRecord::RecordInvalid => e
    Result.failure(e.record.errors)
  end
  
  def bulk_complete(todo_ids)
    todos = Todo.where(id: todo_ids)
    completed_count = todos.update_all(completed: true)
    Result.success(message: "#{completed_count} todos marked as complete")
  end
  
  def bulk_delete(todo_ids)
    deleted_count = Todo.where(id: todo_ids).destroy_all.count
    Result.success(message: "#{deleted_count} todos deleted")
  end
  
  private
  
  # Simple Result object for service responses
  class Result
    attr_reader :data, :errors
    
    def initialize(success, data = nil, errors = nil)
      @success = success
      @data = data
      @errors = errors
    end
    
    def self.success(data = nil)
      new(true, data)
    end
    
    def self.failure(errors = nil)
      new(false, nil, errors)
    end
    
    def success?
      @success
    end
    
    def failure?
      !@success
    end
  end
end

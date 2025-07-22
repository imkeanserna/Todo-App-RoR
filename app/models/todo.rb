class Todo < ApplicationRecord
  # Validations
  validates :title, presence: true, length: { minimum: 1, maximum: 255 }
  validates :description, length: { maximum: 1000 }

  # Enums
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  # Scopes
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }
  scope :due_soon, -> { where(due_date: Time.current..1.week.from_now) }
  scope :overdue, -> { where("due_date < ? AND completed = ?", Time.current, false) }

  # Instance methods
  def complete!
    update!(completed: true)
  end

  def incomplete!
    update!(completed: false)
  end

  def toggle_completion!
    update!(completed: !completed)
  end

  def overdue?
    due_date.present? && due_date < Time.current && !completed?
  end

  def due_soon?
    due_date.present? && due_date.between?(Time.current, 1.week.from_now)
  end

  def priority_color
    case priority
    when "urgent" then "red"
    when "high" then "orange"
    when "medium" then "yellow"
    else "green"
    end
  end
end

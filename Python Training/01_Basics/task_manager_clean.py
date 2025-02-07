"""
Task Manager Application

A simple command-line task manager to demonstrate Python concepts.
This program helps users manage their tasks with features like:
- Adding tasks with priorities
- Listing all tasks
- Marking tasks as complete
"""

from datetime import datetime

# Global variables
tasks = []  # List to store all tasks
PRIORITY_LEVELS = ['LOW', 'MEDIUM', 'HIGH']  # Valid priority levels

def add_task(title, priority='LOW'):
    """Creates a new task and adds it to our task list."""
    if priority not in PRIORITY_LEVELS:
        print(f"Error: Priority must be one of {PRIORITY_LEVELS}")
        return False
    
    new_task = {
        'title': title,
        'priority': priority,
        'created_at': datetime.now(),
        'completed': False
    }
    
    tasks.append(new_task)
    return True

def list_tasks():
    """Displays all tasks with their details."""
    if len(tasks) == 0:
        print("No tasks found!")
        return
    
    for index, task in enumerate(tasks):
        print(f"\nTask {index + 1}:")
        print(f"Title: {task['title']}")
        print(f"Priority: {task['priority']}")
        print(f"Created: {task['created_at'].strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Status: {'Completed' if task['completed'] else 'Pending'}")

def complete_task(index):
    """Marks a task as completed."""
    try:
        tasks[index - 1]['completed'] = True
        return True
    except IndexError:
        print(f"Error: No task found at number {index}")
        return False
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return False

def main():
    """Main program loop."""
    while True:
        print("\n=== Task Manager ===")
        print("1. Add Task")
        print("2. List Tasks")
        print("3. Complete Task")
        print("4. Exit")
        
        choice = input("\nEnter your choice (1-4): ")
        
        match choice:
            case "1":
                title = input("Enter task title: ")
                priority = input(f"Enter priority {PRIORITY_LEVELS}: ").upper()
                if add_task(title, priority):
                    print("Task added successfully!")
            
            case "2":
                list_tasks()
            
            case "3":
                task_index = int(input("Enter task number to complete: "))
                if complete_task(task_index):
                    print("Task marked as complete!")
            
            case "4":
                print("Goodbye!")
                break
            
            case _:
                print("Invalid choice! Please try again.")

if __name__ == "__main__":
    main()

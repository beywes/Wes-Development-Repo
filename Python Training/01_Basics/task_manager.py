"""
Task Manager Application
This is a simple command-line task manager that demonstrates basic Python concepts.
Each line of code is extensively documented to explain Python syntax and concepts.
"""

# ====== IMPORTING MODULES ======
# WHAT IS A MODULE?
# - A module is a file containing Python code (definitions, functions, variables)
# - Modules help organize code by grouping related functionality together
# - Python comes with many built-in modules (like datetime, math, random)
# - You can also create your own modules or install third-party modules
# - Modules help avoid naming conflicts and make code reusable

# WAYS TO IMPORT MODULES:
# 1. import module_name
#    - Imports the entire module
#    - You must use module_name.thing_you_want to access contents
#    Example: import datetime
#            current_time = datetime.datetime.now()

# 2. from module_name import thing_you_want
#    - Imports specific items from a module
#    - You can directly use the imported item without module_name prefix
#    - This is what we're doing below with 'datetime'

# 3. from module_name import *
#    - Imports everything from a module (not recommended)
#    - Can lead to naming conflicts
#    - Makes it unclear where things come from

# THE 'FROM' KEYWORD:
# - 'from' specifies which module you want to import from
# - It's like telling Python "look inside this module"
# - Without 'from', you'd need to write datetime.datetime.now()
# - With 'from datetime import datetime', you can just write datetime.now()
from datetime import datetime  # Import the datetime class from the datetime module

# ====== VARIABLES AND DATA TYPES ======
# UNDERSTANDING LISTS IN PYTHON:
# What is a List?
# - A list is like a container that can hold multiple items
# - Think of it like a shopping list or a to-do list in real life
# - Lists can store any type of data (numbers, strings, even other lists)
# - Lists are ordered (items stay in the order you put them)
# - Lists are mutable (you can change, add, or remove items)

# How to Create Lists:
# 1. Empty list:    my_list = []
# 2. With items:    my_list = [1, 2, 3]
# 3. Mixed types:   my_list = ["hello", 42, True, 3.14]

# Common List Operations:
# - Add item:       my_list.append(item)    # Adds to end
# - Remove item:    my_list.remove(item)    # Removes first occurrence
# - Get item:       my_list[0]              # Gets first item (positions start at 0)
# - Length:         len(my_list)            # Number of items
# - Check if empty: if not my_list:         # True if list is empty

# Why We're Creating an Empty List:
tasks = []  # Initialize an empty list to store our tasks
# - We start with an empty list because we don't have any tasks yet
# - As users add tasks, we'll append them to this list
# - Each task will be a dictionary containing task details
# - Example of how it will look with tasks:
#   tasks = [
#       {"title": "Buy groceries", "priority": "HIGH", "completed": False},
#       {"title": "Call mom", "priority": "MEDIUM", "completed": True}
#   ]

# UNDERSTANDING CONSTANTS IN PYTHON:
# What is a Constant?
# - A constant is a variable whose value should never change during program execution
# - Think of it like a rule or setting that stays the same throughout your program
# - Examples in real life:
#   * The number of days in a week (always 7)
#   * The value of π (pi) in mathematics (always 3.14159...)
#   * The maximum score in a game (e.g., always 100)

# The UPPERCASE Convention:
# - Python doesn't have built-in constant types (unlike some other languages)
# - Using UPPERCASE names is a coding convention (an agreed-upon rule)
# - When other programmers see UPPERCASE variables, they know:
#   * This value should not be changed
#   * This is a program-wide setting or rule
#   * Changing this value might break the program
# Examples:
#   MAX_SPEED = 120          # A speed limit that won't change
#   DATABASE_NAME = "users"  # Database name used throughout the program
#   GAME_LEVELS = [1, 2, 3]  # Fixed levels in a game

# Why We're Creating PRIORITY_LEVELS as a Constant:
PRIORITY_LEVELS = ['LOW', 'MEDIUM', 'HIGH']  # List of valid priority levels
# 1. Program Rules:
#    - These are the only valid priority levels in our task manager
#    - Users can't create their own priority levels
#    - All tasks must use one of these three levels
#
# 2. Code Organization:
#    - Having it as a constant means we define priority levels in one place
#    - If we want to add/change priorities later, we only change one line
#    - Every function that needs to check priorities uses this same list
#
# 3. Error Prevention:
#    - We can check if a priority is valid by checking if it's in PRIORITY_LEVELS
#    - Prevents users from entering invalid priorities like "SUPER HIGH" or "URGENT"
#    - Helps maintain consistent data in our task manager
#
# 4. Code Readability:
#    - UPPERCASE name makes it clear these are the official priority levels
#    - Other programmers know not to modify this list
#    - Makes the code self-documenting (explains itself)

# ====== FUNCTIONS ======
# UNDERSTANDING FUNCTIONS IN PYTHON:
# What is a Function?
# - A function is like a recipe that performs a specific task
# - It's a reusable block of code that you can call (use) multiple times
# - Functions help organize code and avoid repetition
#
# Real-world analogy:
# Think of a function like a coffee machine:
# - Input (parameters): water, coffee beans, cup size
# - Process: The machine does its work
# - Output (return value): Your cup of coffee
#
# Function Structure:
# def function_name(parameter1, parameter2, ...):
#     # Function code goes here
#     return some_value
#
# - 'def': Tells Python you're defining a function
# - 'function_name': The name you use to call the function
# - 'parameters': Information the function needs to do its job
# - 'return': The result the function gives back

# UNDERSTANDING PARAMETERS:
# - Parameters are like ingredients a recipe needs
# - They are variables that hold values passed to the function
# Types of Parameters:
# 1. Required parameters: Must be provided
# 2. Optional parameters: Have default values
#
# Example with both types:
# def make_coffee(size, type="regular"):  # type has default value "regular"
#    return f"Making {size} {type} coffee"
#
# You can call this function in different ways:
# make_coffee("large")          # Uses default type
# make_coffee("small", "decaf") # Specifies both parameters

# Let's look at our first function in detail:
def add_task(title, priority='LOW'):
    """
    Creates a new task and adds it to our task list.
    
    Think of this function like filling out a form:
    - title: The name of your task (required)
    - priority: How urgent it is (optional, defaults to 'LOW')
    
    Parameters:
        title (str): Like a label for your task
            Example: "Buy groceries", "Call mom"
        
        priority (str, optional): How important the task is
            - Must be one of: 'LOW', 'MEDIUM', 'HIGH'
            - If not specified, assumes 'LOW'
            Example: "HIGH" for urgent tasks
    
    Returns:
        bool: True if task was added successfully, False if there was an error
        (Like a receipt confirming your task was added)
    """
    # ====== PRIORITY VALIDATION SECTION ======
    # Let's break this code down piece by piece:
    
    # 1. THE 'IF' STATEMENT:
    # - 'if' is like asking a yes/no question
    # - It's similar to how we make decisions in real life:
    #   "IF it's raining, take an umbrella"
    #   "IF the store is open, buy groceries"
    
    # 2. THE 'not in' OPERATOR:
    # - 'in' checks if something is inside a collection (like our PRIORITY_LEVELS list)
    # - 'not in' is the opposite - it checks if something is NOT in the collection
    # Example:
    # fruits = ['apple', 'banana', 'orange']
    # 'apple' in fruits      -> True (yes, apple is in the list)
    # 'grape' not in fruits  -> True (yes, grape is NOT in the list)
    
    # 3. PUTTING IT TOGETHER:
    if priority not in PRIORITY_LEVELS:    # Remember: PRIORITY_LEVELS = ['LOW', 'MEDIUM', 'HIGH']
        # This line means:
        # "IF the priority value is NOT one of: 'LOW', 'MEDIUM', or 'HIGH', then..."
        
        # 4. THE PRINT STATEMENT:
        # - 'print' shows a message to the user
        # - The 'f' before the string makes it an "f-string" (formatted string)
        # - Anything inside {} in an f-string gets replaced with its actual value
        print(f"Error: Priority must be one of {PRIORITY_LEVELS}")
        # If PRIORITY_LEVELS is ['LOW', 'MEDIUM', 'HIGH'], this will show:
        # "Error: Priority must be one of ['LOW', 'MEDIUM', 'HIGH']"
        
        # 5. THE RETURN STATEMENT:
        # - 'return False' means "stop here and tell the program this didn't work"
        # - It's like returning a "no" answer
        # - The function stops here if the priority isn't valid
        return False
    
    # If we get past the if statement, it means the priority was valid
    # and the code continues...
    
    # EXAMPLE SCENARIOS:
    # Scenario 1:
    # priority = 'LOW'
    # 'LOW' is in PRIORITY_LEVELS, so code continues
    #
    # Scenario 2:
    # priority = 'URGENT'
    # 'URGENT' is not in PRIORITY_LEVELS, so:
    # - Shows error message
    # - Returns False
    # - Function stops here

    # ====== CREATING AND STORING A TASK ======
    # Let's understand how we store task information:
    
    # 1. DICTIONARY CREATION:
    # - A dictionary is like a form with labeled fields
    # - Each line is a field with a label (key) and value
    # - The curly braces {} create a dictionary
    new_task = {
        # Field 1: Task Title
        'title': title,            # Like writing the task name on a form
                                  # Example: title = "Buy groceries"
        
        # Field 2: Priority Level
        'priority': priority,      # The priority we checked earlier
                                  # Example: priority = "HIGH"
        
        # Field 3: Creation Time
        'created_at': datetime.now(),  # Gets current date and time
                                      # Example: 2025-02-06 15:00:08
        
        # Field 4: Completion Status
        'completed': False         # Task starts as not completed
                                  # Like an unchecked checkbox
    }
    
    # 2. STORING THE TASK:
    # - Remember our tasks list from the beginning of the file?
    # - append() adds the new task to the end of that list
    # - It's like adding a new page to a notebook
    tasks.append(new_task)
    
    # 3. CONFIRMING SUCCESS:
    # - Return True means "everything worked!"
    # - Like giving a thumbs up
    return True

# ====== HOW THIS FUNCTION FITS IN THE BIGGER PICTURE ======
#
# FUNCTION HIERARCHY:
# 1. User Interface Level:
#    - Users type commands in the main menu
#    - When they choose "Add Task", this function runs
#
# 2. Function Level (where we are):
#    def add_task(title, priority='LOW'):
#    - Gets information from the user
#    - Validates it
#    - Stores it
#
# 3. Data Storage Level:
#    - Tasks are stored in the tasks list
#    - Each task is a dictionary with details
#
# HOW USERS INTERACT WITH THIS FUNCTION:
#
# Example 1: Adding a simple task
# > add_task("Buy groceries")
# - title will be "Buy groceries"
# - priority will be "LOW" (default value)
# - Result: Task added with low priority
#
# Example 2: Adding an urgent task
# > add_task("Pay electric bill", priority="HIGH")
# - title will be "Pay electric bill"
# - priority will be "HIGH"
# - Result: Task added with high priority
#
# Example 3: Adding with invalid priority
# > add_task("Call mom", priority="SUPER HIGH")
# - This will fail our priority check
# - User gets error message
# - No task is added
#
# OVERALL FUNCTION LOGIC (for beginners):
# Think of this function like a form processor:
#
# 1. Someone gives you a form (function call with parameters)
#    add_task("Buy groceries", "HIGH")
#
# 2. Check if it's filled out correctly (validation)
#    - Is the priority valid? (LOW, MEDIUM, or HIGH)
#    - If not, return the form (return False)
#
# 3. If everything's okay:
#    - Create a new entry (dictionary) with:
#      * The task name (title)
#      * How important it is (priority)
#      * When it was created (current time)
#      * Status (not completed)
#
# 4. File the form away (append to tasks list)
#
# 5. Confirm it's done (return True)
#
# This function is like a helpful assistant that:
# - Takes your task information
# - Makes sure it's valid
# - Organizes it properly
# - Stores it where it can be found later
# - Lets you know it was successful

# Another example function that shows different parameter usage:
def list_tasks():
    """
    Shows all tasks in our list.
    
    This function has no parameters because it doesn't need any information
    to do its job - it just shows what's already in our task list.
    
    Think of it like asking to see everything in your to-do list.
    
    Returns:
        None: This function doesn't return anything, it just prints information
        (Like reading your to-do list out loud)
    """
    # Check if the list is empty
    if len(tasks) == 0:
        print("No tasks found!")
        return
    
    # Show each task's details
    for index, task in enumerate(tasks):
        # Print task information in a readable format
        print(f"\nTask {index + 1}:")  # Add 1 because humans count from 1
        print(f"Title: {task['title']}")
        print(f"Priority: {task['priority']}")
        print(f"Created: {task['created_at'].strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Status: {'Completed' if task['completed'] else 'Pending'}")

def complete_task(index):
    """
    Marks a task as finished.
    
    Parameters:
        index (int): Which task to complete (task number)
            - Must be a positive number
            - Must be a valid task number (can't complete task 5 if you only have 3 tasks)
            Example: 1 for first task, 2 for second task, etc.
    
    Think of it like checking off an item on your to-do list.
    
    Returns:
        bool: True if task was marked complete, False if there was an error
        (Like getting a confirmation that you checked off the right item)
    """
    try:
        # Convert from human-friendly number (1-based) to computer-friendly (0-based)
        # Humans count from 1, computers count from 0
        tasks[index - 1]['completed'] = True
        return True
    except IndexError:  # If the task number doesn't exist
        print(f"Error: No task found at number {index}")
        return False
    except Exception as e:  # If something else goes wrong
        print(f"An error occurred: {str(e)}")
        return False

# ====== MAIN PROGRAM ======
# Special variable __name__ is set to "__main__" when script is run directly
if __name__ == "__main__":
    # Infinite loop using while True
    while True:
        # Print menu options
        print("\n=== Task Manager ===")
        print("1. Add Task")
        print("2. List Tasks")
        print("3. Complete Task")
        print("4. Exit")
        
        # Input function gets user input as string
        choice = input("\nEnter your choice (1-4): ")
        
        # Match statement (Python 3.10+) - similar to switch in other languages
        match choice:
            case "1":
                # Get task details from user
                title = input("Enter task title: ")
                priority = input(f"Enter priority {PRIORITY_LEVELS}: ").upper()
                if add_task(title, priority):
                    print("Task added successfully!")
            
            case "2":
                list_tasks()
            
            case "3":
                # int() converts string to integer
                task_index = int(input("Enter task number to complete: "))
                if complete_task(task_index):
                    print("Task marked as complete!")
            
            case "4":
                print("Goodbye!")
                # break statement exits the loop
                break
            
            case _:  # Default case
                print("Invalid choice! Please try again.")

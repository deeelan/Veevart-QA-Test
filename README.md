# Veevart-QA-Test
Deelan: Veevart QA Test

# HOW TO OPEN DEVELOPER CONSOLE:

    1. Go to https://test.salesforce.com/ and log with the following credentials

        Username: test-i3j5jrrfjzgn@example.com
        Password: !4Qmsewpxqjfk

    2. In the upper-right side click in the Gear icon > Developer Console
    3. Once the Developer Console has open, go to Debug > Open Execute Anonymous Window

## HOW TO RUN THE CODE:

    - To delete a single Task: ToDoList.deleteToDoRecord(Task)
    - To delete a list of Tasks: ToDoList.deleteToDoRecords(List<TasK>)
    - To create/update a Task: ToDoList.saveToDoRecord(Task)
    - To get a Task: ToDoList.loadData(ToDoList.TASK_STATUS) | TASK_STATUS{IN_PROGRESS,COMPLETED}

    All methods you get a response:

    {
        // if operation failed or not
        "isSuccess": Boolean,

        // records involved in the operation
        "toDoRecords": Task[],
        
        // message when it fails
        "message": String
    }

See QA Document at: https://docs.google.com/document/d/1p0tMETgGeKC58hRnjcHZqoNk33r0YVE8dxJX8huNRrI/edit#
/**
 * @description       : TO-DO list  
 * @author            : Veevart Developer
 * @group             : QA Test
 * @last modified on  : 10-25-2021
 * @last modified by  : Dilan Madhava Chávez Molano
 * 
 * Test in Console:
    Database.delete([SELECT Id FROM Task],false);
    String list1 = ToDoList.loadData(ToDoList.TASK_STATUS.IN_PROGRESS);
    String list2 = ToDoList.loadData(ToDoList.TASK_STATUS.COMPLETED);
    System.debug('In pregress tasks ==> '+ list1);
    System.debug('Completed tasks ==> '+ list2);
    System.debug('Test 1');
    System.debug('=======================');
    String insert1 = ToDoList.saveToDoRecord(new Task(Description='1. First QA', Status='In Progress'));
    String insert2 = ToDoList.saveToDoRecord(new Task(Description='2. First QA', Status='Completed'));
    String insert3 = ToDoList.saveToDoRecord(new Task(Description='3. First QA', Status='Completed'));
    list1 = ToDoList.loadData(ToDoList.TASK_STATUS.IN_PROGRESS);
    System.debug('In pregress tasks ==> '+ list1);
    list2 = ToDoList.loadData(ToDoList.TASK_STATUS.COMPLETED);
    System.debug('Completed tasks ==> '+ list2);
    System.debug('=======================');
    System.debug('Test 2');
    System.debug('=======================');
    ToDoList.Response insert3R = (ToDoList.Response) JSON.deserialize(insert3, ToDoList.Response.class);
    insert3R.toDoRecords[0].Status = 'In Progress';
    String update3 = ToDoList.saveToDoRecord(insert3R.toDoRecords[0]);
    list1 = ToDoList.loadData(ToDoList.TASK_STATUS.IN_PROGRESS);
    System.debug('In pregress tasks ==> '+ list1);
    list2 = ToDoList.loadData(ToDoList.TASK_STATUS.COMPLETED);
    System.debug('Completed tasks ==> '+ list2);
    System.debug('=======================');
    System.debug('Test 3');
    System.debug('=======================');
    ToDoList.Response insert1R = (ToDoList.Response) JSON.deserialize(insert1, ToDoList.Response.class);
    String delete1 = ToDoList.deleteToDoRecord(String.valueOf(insert1R.toDoRecords[0].Id));
    list1 = ToDoList.loadData(ToDoList.TASK_STATUS.IN_PROGRESS);
    System.debug('In pregress tasks ==> '+ list1);
    list2 = ToDoList.loadData(ToDoList.TASK_STATUS.COMPLETED);
    System.debug('Completed tasks ==> '+ list2);
    System.debug('=======================');
**/
public with sharing class ToDoList {
    /**
     * Task status to filter the loadData. 
     */
    public Enum TASK_STATUS {IN_PROGRESS,COMPLETED}
    
    /**
     * Method to return list of task during component initialization 
     * @param taskStatusCode enum value to filter Task by statuses
     * @returns String serialized response wrapper class
     */
    @AuraEnabled
    public static String loadData(TASK_STATUS taskStatusCode){
        try {
            String statusCode = taskStatusCode == TASK_STATUS.IN_PROGRESS ? 'In Progress' : 'Completed';

            //Retrive the list of task that has the status given
            Response response = new Response([SELECT Id, Description, ActivityDate FROM Task WHERE Status = :statusCode]);
            
            //Response the user with the list of taks that has the status given
            return JSON.serialize(response);
        } catch (Exception e) {
            //Response the user with the DML/SOQL exception message 
            return JSON.serialize(new Response(e.getMessage()));
        }
    }

    /**
     * Method to save a task, it would update it if exists, create the record if not
     * @param toDoRecord record to save
     * @returns String serialized response wrapper class
     */
    @AuraEnabled
    public static string saveToDoRecord(Task toDoRecord){
        try {
            Database.UpsertResult sr = Database.upsert(toDoRecord,false);
            
            //Add all errors to message 
            String message; 
            if (!sr.isSuccess()) {
                for (Database.Error error : sr.errors) {
                    message += error.getMessage();
                }
            } 

            //Response the user with the upsert errors
            if (message != null) {
                return JSON.serialize(new Response(message));
            } 

            //Response the user with the task updated/inserted.
            return JSON.serialize(new Response(toDoRecord));

        } catch (Exception e) {
            //Response the user with the DML/SOQL exception message
            return JSON.serialize(new Response(e.getMessage()));
        }
    }

    /**
     * Method to delete a task during component delete record.
     * @param toDoRecordId id of the task to delete
     * @returns String serialized response wrapper class
     */
    @AuraEnabled
    public static string deleteToDoRecord(String toDoRecordId){
        try {
            Database.DeleteResult dr = Database.delete((Id) toDoRecordId, false);

            //Add all errors to message 
            String message; 

            if (!dr.isSuccess()) {
                for (Database.Error error : dr.errors) {
                    message += error.getMessage();
                }
            }

            //Response the user with the upsert errors
            if (message != null) {
                return JSON.serialize(new Response(message));
            } 

            //Response the user with the task delete.
            return JSON.serialize(new Response());

        } catch (Exception e) {
            //Response the user with the DML/SOQL exception message
            return JSON.serialize(new Response(e.getMessage()));
        }
    }

    /**
     * Method to delete a list of tasks
     * @param toDoRecords records to delete
     * @returns String response of the tasks filtered by their status
     */
    @AuraEnabled
    public static string deleteToDoRecords(Task[] toDoRecords){
        try {
            Set<Id> recordIds = (new Map<Id,Task>(toDoRecords)).keySet();
            //send to handler method to delete
            deleteToDoRecordsHandler(new List<Id>(recordIds));
        } catch (Exception e) {
            //Response the user with the DML/SOQL exception message
            return JSON.serialize(new Response(e.getMessage()));
        }
    }

    /**
     * Handler method to delete tasks
     * @param toDoRecordIds list of ids to delete records
     */
    private static Void deleteToDoRecordsHandler(Id[] toDoRecordIds){
        try {
            for (Id uid : toDoRecordIds){
                //instance the object with id
                Task tsk = new Task(Id = uid);
                Database.DeleteResult dr = Database.delete(tsk, false);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Response wrapper class
     */
    public class Response {
        /**
         * False if response an error
         */
        Boolean isSuccess;

        /**
         * List of task requested
         */
        public Task[] toDoRecords;

        /**
         * Error message to display to the user
         */
        String message;

        /**
         * CONSTRUCTOR METHOD
         */
        Response() {
            this.isSuccess = true;
        }

        /**
         * CONSTRUCTOR METHOD
         * @param toDoRecords list of task to create Response object  
         */
        Response(Task[] toDoRecords) {
            this();
            this.toDoRecords=toDoRecords;
        }

        /**
         * CONSTRUCTOR METHOD
         * !constructor method to an error Response
         * @param message error message to response
         */
        Response(String message) {
            this.isSuccess = false;
            this.message=message;
        }

        /**
         * CONSTRUCTOR METHOD
         * @param toDoRecord single record to create Response object
         */
        Response(Task todoRecord) {
            this(new Task[]{todoRecord});
        }
    }
}

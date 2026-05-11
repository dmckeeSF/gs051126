/**
 * @description Invocable Apex action for creating custom object records with dynamic fields
 * @author Claude Code
 * @date 2026-05-11
 */
public with sharing class CreateCustomObjectAction {

    /**
     * @description Input parameters for the invocable action
     */
    public class CreateRecordInput {
        @InvocableVariable(label='Object API Name' description='API name of the custom object to create' required=true)
        public String objectApiName;

        @InvocableVariable(label='Field Values (JSON)' description='JSON string containing field API names and values. Example: {"Name":"Test","CustomField__c":"Value"}' required=true)
        public String fieldValuesJson;
    }

    /**
     * @description Output parameters for the invocable action
     */
    public class CreateRecordOutput {
        @InvocableVariable(label='Record Id' description='ID of the created record')
        public String recordId;

        @InvocableVariable(label='Success' description='Whether the record was created successfully')
        public Boolean isSuccess;

        @InvocableVariable(label='Error Message' description='Error message if creation failed')
        public String errorMessage;
    }

    /**
     * @description Creates a record with dynamic fields
     * @param inputs List of input parameters
     * @return List of output results
     */
    @InvocableMethod(
        label='Create Custom Object Record'
        description='Creates a custom object record with dynamic fields provided as JSON'
        category='Agentforce Actions'
    )
    public static List<CreateRecordOutput> createRecord(List<CreateRecordInput> inputs) {
        List<CreateRecordOutput> outputs = new List<CreateRecordOutput>();

        for (CreateRecordInput input : inputs) {
            CreateRecordOutput output = new CreateRecordOutput();
            output.isSuccess = false;

            try {
                // Validate input
                if (String.isBlank(input.objectApiName)) {
                    throw new IllegalArgumentException('Object API Name is required');
                }

                if (String.isBlank(input.fieldValuesJson)) {
                    throw new IllegalArgumentException('Field Values JSON is required');
                }

                // Parse the JSON field values
                Map<String, Object> fieldValues = (Map<String, Object>) JSON.deserializeUntyped(input.fieldValuesJson);

                // Create SObject dynamically
                Schema.SObjectType objectType = Schema.getGlobalDescribe().get(input.objectApiName);
                if (objectType == null) {
                    throw new IllegalArgumentException('Object not found: ' + input.objectApiName);
                }

                SObject newRecord = objectType.newSObject();

                // Set field values
                Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
                for (String fieldName : fieldValues.keySet()) {
                    if (!fieldMap.containsKey(fieldName)) {
                        throw new IllegalArgumentException('Field not found on object: ' + fieldName);
                    }

                    Object fieldValue = fieldValues.get(fieldName);
                    Schema.DisplayType fieldType = fieldMap.get(fieldName).getDescribe().getType();

                    // Type conversion based on field type
                    newRecord.put(fieldName, convertFieldValue(fieldValue, fieldType));
                }

                // Insert the record
                insert newRecord;

                output.recordId = newRecord.Id;
                output.isSuccess = true;

            } catch (Exception e) {
                output.isSuccess = false;
                output.errorMessage = e.getMessage();
            }

            outputs.add(output);
        }

        return outputs;
    }

    /**
     * @description Converts field value to appropriate type
     * @param value The value to convert
     * @param fieldType The target field type
     * @return Converted value
     */
    private static Object convertFieldValue(Object value, Schema.DisplayType fieldType) {
        if (value == null) {
            return null;
        }

        switch on fieldType {
            when BOOLEAN {
                return Boolean.valueOf(value);
            }
            when INTEGER {
                return Integer.valueOf(value);
            }
            when DOUBLE, CURRENCY, PERCENT {
                return Decimal.valueOf(String.valueOf(value));
            }
            when DATE {
                return Date.valueOf(String.valueOf(value));
            }
            when DATETIME {
                return DateTime.valueOf(String.valueOf(value));
            }
            when else {
                return String.valueOf(value);
            }
        }
    }
}

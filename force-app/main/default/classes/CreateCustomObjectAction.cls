/**
 * @description Invocable Apex action for creating Opportunity records with fields from Field Set
 * @author Claude Code
 * @date 2026-05-12
 */
public with sharing class CreateCustomObjectAction {

    private static final String FIELD_SET_NAME = 'Agentforce_Create_Fields';

    /**
     * @description Input parameters for the invocable action
     */
    public class CreateRecordInput {
        @InvocableVariable(label='Field Values (JSON)' description='JSON string containing field API names and values. Example: {"Name":"Test Opportunity","StageName":"Prospecting","CloseDate":"2026-12-31"}' required=true)
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
     * @description Creates an Opportunity record with fields from Field Set
     * @param inputs List of input parameters
     * @return List of output results
     */
    @InvocableMethod(
        label='Create Opportunity'
        description='Creates an Opportunity record with fields defined in the Agentforce_Create_Fields Field Set'
        category='Agentforce Actions'
    )
    public static List<CreateRecordOutput> createRecord(List<CreateRecordInput> inputs) {
        List<CreateRecordOutput> outputs = new List<CreateRecordOutput>();

        for (CreateRecordInput input : inputs) {
            CreateRecordOutput output = new CreateRecordOutput();
            output.isSuccess = false;

            try {
                // Validate input
                if (String.isBlank(input.fieldValuesJson)) {
                    throw new IllegalArgumentException('Field Values JSON is required');
                }

                // Parse the JSON field values
                Map<String, Object> fieldValues = (Map<String, Object>) JSON.deserializeUntyped(input.fieldValuesJson);

                // Get allowed fields from Field Set
                Set<String> allowedFields = getAllowedFieldsFromFieldSet();
                if (allowedFields.isEmpty()) {
                    throw new IllegalArgumentException('Field Set "' + FIELD_SET_NAME + '" not found or is empty on Opportunity object');
                }

                // Create Opportunity
                Opportunity newOpp = new Opportunity();

                // Get field metadata
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Opportunity.fields.getMap();

                // Set field values (only if in Field Set)
                for (String fieldName : fieldValues.keySet()) {
                    String fieldNameLower = fieldName.toLowerCase();

                    if (!allowedFields.contains(fieldNameLower)) {
                        throw new IllegalArgumentException('Field "' + fieldName + '" is not in the configured Field Set');
                    }

                    if (!fieldMap.containsKey(fieldNameLower)) {
                        throw new IllegalArgumentException('Field not found on Opportunity: ' + fieldName);
                    }

                    Object fieldValue = fieldValues.get(fieldName);
                    Schema.SObjectField fieldToken = fieldMap.get(fieldNameLower);
                    Schema.DisplayType fieldType = fieldToken.getDescribe().getType();

                    // Type conversion based on field type
                    newOpp.put(fieldToken, convertFieldValue(fieldValue, fieldType));
                }

                // Validate required fields
                validateRequiredFields(newOpp, allowedFields, fieldMap);

                // Insert the record
                insert newOpp;

                output.recordId = newOpp.Id;
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
     * @description Gets allowed fields from the Field Set
     * @return Set of field API names (lowercase)
     */
    private static Set<String> getAllowedFieldsFromFieldSet() {
        Set<String> allowedFields = new Set<String>();

        Schema.FieldSet fieldSet = Schema.SObjectType.Opportunity.fieldSets.getMap().get(FIELD_SET_NAME);
        if (fieldSet != null) {
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                allowedFields.add(field.getFieldPath().toLowerCase());
            }
        }

        return allowedFields;
    }

    /**
     * @description Validates that all required fields are populated
     * @param opp The Opportunity record
     * @param allowedFields Set of allowed field names
     * @param fieldMap Map of field API names to field tokens
     */
    private static void validateRequiredFields(Opportunity opp, Set<String> allowedFields, Map<String, Schema.SObjectField> fieldMap) {
        List<String> missingFields = new List<String>();

        for (String fieldName : allowedFields) {
            Schema.SObjectField fieldToken = fieldMap.get(fieldName);
            if (fieldToken != null) {
                Schema.DescribeFieldResult fieldDescribe = fieldToken.getDescribe();

                // Check if required and not populated
                if (!fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate()) {
                    Object fieldValue = opp.get(fieldToken);
                    if (fieldValue == null) {
                        missingFields.add(fieldDescribe.getLabel());
                    }
                }
            }
        }

        if (!missingFields.isEmpty()) {
            throw new IllegalArgumentException('Missing required fields: ' + String.join(missingFields, ', '));
        }
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

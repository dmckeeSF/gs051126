/**
 * @description Invocable Apex action that returns available Opportunity fields from Field Set
 * @author Claude Code
 * @date 2026-05-12
 */
public with sharing class GetOpportunityFieldsAction {

    private static final String FIELD_SET_NAME = 'Agentforce_Create_Fields';

    /**
     * @description Output parameters containing field metadata
     */
    public class FieldMetadata {
        @InvocableVariable(label='Field API Name' description='API name of the field')
        public String apiName;

        @InvocableVariable(label='Field Label' description='User-friendly label')
        public String label;

        @InvocableVariable(label='Field Type' description='Data type (TEXT, PICKLIST, DATE, etc.)')
        public String fieldType;

        @InvocableVariable(label='Is Required' description='Whether the field is required')
        public Boolean isRequired;

        @InvocableVariable(label='Help Text' description='Field help text or description')
        public String helpText;

        @InvocableVariable(label='Picklist Values' description='Available picklist values (comma-separated)')
        public String picklistValues;
    }

    /**
     * @description Output wrapper for the invocable action
     */
    public class GetFieldsOutput {
        @InvocableVariable(label='Fields (JSON)' description='JSON array of available fields with metadata')
        public String fieldsJson;

        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean isSuccess;

        @InvocableVariable(label='Error Message' description='Error message if operation failed')
        public String errorMessage;
    }

    /**
     * @description Gets available Opportunity fields from Field Set
     * @return List of output results
     */
    @InvocableMethod(
        label='Get Opportunity Fields'
        description='Returns available Opportunity fields from the Agentforce_Create_Fields Field Set'
        category='Agentforce Actions'
    )
    public static List<GetFieldsOutput> getFields() {
        List<GetFieldsOutput> outputs = new List<GetFieldsOutput>();
        GetFieldsOutput output = new GetFieldsOutput();
        output.isSuccess = false;

        try {
            // Get Field Set
            Schema.FieldSet fieldSet = Schema.SObjectType.Opportunity.fieldSets.getMap().get(FIELD_SET_NAME);
            if (fieldSet == null) {
                throw new IllegalArgumentException('Field Set "' + FIELD_SET_NAME + '" not found on Opportunity object');
            }

            // Build field metadata
            List<FieldMetadata> fieldMetadataList = new List<FieldMetadata>();
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Opportunity.fields.getMap();

            for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
                String fieldPath = fsm.getFieldPath();
                Schema.SObjectField fieldToken = fieldMap.get(fieldPath.toLowerCase());

                if (fieldToken != null) {
                    Schema.DescribeFieldResult fieldDescribe = fieldToken.getDescribe();
                    FieldMetadata metadata = new FieldMetadata();

                    metadata.apiName = fieldDescribe.getName();
                    metadata.label = fieldDescribe.getLabel();
                    metadata.fieldType = String.valueOf(fieldDescribe.getType());
                    metadata.isRequired = fsm.getRequired() || (!fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate());
                    metadata.helpText = fieldDescribe.getInlineHelpText();

                    // Get picklist values if applicable
                    if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST ||
                        fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST) {
                        List<String> picklistLabels = new List<String>();
                        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                            if (entry.isActive()) {
                                picklistLabels.add(entry.getLabel());
                            }
                        }
                        metadata.picklistValues = String.join(picklistLabels, ', ');
                    }

                    fieldMetadataList.add(metadata);
                }
            }

            // Convert to JSON
            output.fieldsJson = JSON.serializePretty(fieldMetadataList);
            output.isSuccess = true;

        } catch (Exception e) {
            output.isSuccess = false;
            output.errorMessage = e.getMessage();
        }

        outputs.add(output);
        return outputs;
    }
}

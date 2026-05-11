/**
 * @description Test class for CreateCustomObjectAction
 * @author Claude Code
 * @date 2026-05-11
 */
@IsTest
private class CreateCustomObjectActionTest {

    /**
     * @description Test successful record creation
     */
    @IsTest
    static void testCreateRecordSuccess() {
        // Arrange
        CreateCustomObjectAction.CreateRecordInput input = new CreateCustomObjectAction.CreateRecordInput();
        input.objectApiName = 'Account';
        input.fieldValuesJson = '{"Name":"Test Account","Industry":"Technology"}';

        List<CreateCustomObjectAction.CreateRecordInput> inputs = new List<CreateCustomObjectAction.CreateRecordInput>{input};

        // Act
        Test.startTest();
        List<CreateCustomObjectAction.CreateRecordOutput> outputs = CreateCustomObjectAction.createRecord(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, outputs.size(), 'Should return one output');
        CreateCustomObjectAction.CreateRecordOutput output = outputs[0];
        System.assertEquals(true, output.isSuccess, 'Should be successful');
        System.assertNotEquals(null, output.recordId, 'Record ID should be set');
        System.assertEquals(null, output.errorMessage, 'Error message should be null');

        // Verify record was created
        Account acc = [SELECT Id, Name, Industry FROM Account WHERE Id = :output.recordId];
        System.assertEquals('Test Account', acc.Name, 'Name should match');
        System.assertEquals('Technology', acc.Industry, 'Industry should match');
    }

    /**
     * @description Test record creation with custom fields
     */
    @IsTest
    static void testCreateRecordWithCustomFields() {
        // Arrange
        CreateCustomObjectAction.CreateRecordInput input = new CreateCustomObjectAction.CreateRecordInput();
        input.objectApiName = 'Contact';
        input.fieldValuesJson = '{"FirstName":"John","LastName":"Doe","Email":"john.doe@example.com"}';

        List<CreateCustomObjectAction.CreateRecordInput> inputs = new List<CreateCustomObjectAction.CreateRecordInput>{input};

        // Act
        Test.startTest();
        List<CreateCustomObjectAction.CreateRecordOutput> outputs = CreateCustomObjectAction.createRecord(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, outputs.size(), 'Should return one output');
        CreateCustomObjectAction.CreateRecordOutput output = outputs[0];
        System.assertEquals(true, output.isSuccess, 'Should be successful');
        System.assertNotEquals(null, output.recordId, 'Record ID should be set');

        // Verify record was created
        Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :output.recordId];
        System.assertEquals('John', con.FirstName, 'FirstName should match');
        System.assertEquals('Doe', con.LastName, 'LastName should match');
        System.assertEquals('john.doe@example.com', con.Email, 'Email should match');
    }

    /**
     * @description Test with invalid object name
     */
    @IsTest
    static void testCreateRecordInvalidObject() {
        // Arrange
        CreateCustomObjectAction.CreateRecordInput input = new CreateCustomObjectAction.CreateRecordInput();
        input.objectApiName = 'InvalidObject__c';
        input.fieldValuesJson = '{"Name":"Test"}';

        List<CreateCustomObjectAction.CreateRecordInput> inputs = new List<CreateCustomObjectAction.CreateRecordInput>{input};

        // Act
        Test.startTest();
        List<CreateCustomObjectAction.CreateRecordOutput> outputs = CreateCustomObjectAction.createRecord(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, outputs.size(), 'Should return one output');
        CreateCustomObjectAction.CreateRecordOutput output = outputs[0];
        System.assertEquals(false, output.isSuccess, 'Should fail');
        System.assertEquals(null, output.recordId, 'Record ID should be null');
        System.assertNotEquals(null, output.errorMessage, 'Error message should be set');
        System.assert(output.errorMessage.contains('Object not found'), 'Error should mention object not found');
    }

    /**
     * @description Test with invalid field name
     */
    @IsTest
    static void testCreateRecordInvalidField() {
        // Arrange
        CreateCustomObjectAction.CreateRecordInput input = new CreateCustomObjectAction.CreateRecordInput();
        input.objectApiName = 'Account';
        input.fieldValuesJson = '{"Name":"Test","InvalidField__c":"Value"}';

        List<CreateCustomObjectAction.CreateRecordInput> inputs = new List<CreateCustomObjectAction.CreateRecordInput>{input};

        // Act
        Test.startTest();
        List<CreateCustomObjectAction.CreateRecordOutput> outputs = CreateCustomObjectAction.createRecord(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, outputs.size(), 'Should return one output');
        CreateCustomObjectAction.CreateRecordOutput output = outputs[0];
        System.assertEquals(false, output.isSuccess, 'Should fail');
        System.assertEquals(null, output.recordId, 'Record ID should be null');
        System.assertNotEquals(null, output.errorMessage, 'Error message should be set');
        System.assert(output.errorMessage.contains('Field not found'), 'Error should mention field not found');
    }

    /**
     * @description Test with invalid JSON
     */
    @IsTest
    static void testCreateRecordInvalidJson() {
        // Arrange
        CreateCustomObjectAction.CreateRecordInput input = new CreateCustomObjectAction.CreateRecordInput();
        input.objectApiName = 'Account';
        input.fieldValuesJson = 'invalid json';

        List<CreateCustomObjectAction.CreateRecordInput> inputs = new List<CreateCustomObjectAction.CreateRecordInput>{input};

        // Act
        Test.startTest();
        List<CreateCustomObjectAction.CreateRecordOutput> outputs = CreateCustomObjectAction.createRecord(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, outputs.size(), 'Should return one output');
        CreateCustomObjectAction.CreateRecordOutput output = outputs[0];
        System.assertEquals(false, output.isSuccess, 'Should fail');
        System.assertEquals(null, output.recordId, 'Record ID should be null');
        System.assertNotEquals(null, output.errorMessage, 'Error message should be set');
    }

    /**
     * @description Test with empty object name
     */
    @IsTest
    static void testCreateRecordEmptyObjectName() {
        // Arrange
        CreateCustomObjectAction.CreateRecordInput input = new CreateCustomObjectAction.CreateRecordInput();
        input.objectApiName = '';
        input.fieldValuesJson = '{"Name":"Test"}';

        List<CreateCustomObjectAction.CreateRecordInput> inputs = new List<CreateCustomObjectAction.CreateRecordInput>{input};

        // Act
        Test.startTest();
        List<CreateCustomObjectAction.CreateRecordOutput> outputs = CreateCustomObjectAction.createRecord(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, outputs.size(), 'Should return one output');
        CreateCustomObjectAction.CreateRecordOutput output = outputs[0];
        System.assertEquals(false, output.isSuccess, 'Should fail');
        System.assertEquals(null, output.recordId, 'Record ID should be null');
        System.assertNotEquals(null, output.errorMessage, 'Error message should be set');
        System.assert(output.errorMessage.contains('required'), 'Error should mention required field');
    }

    /**
     * @description Test with multiple records
     */
    @IsTest
    static void testCreateMultipleRecords() {
        // Arrange
        CreateCustomObjectAction.CreateRecordInput input1 = new CreateCustomObjectAction.CreateRecordInput();
        input1.objectApiName = 'Account';
        input1.fieldValuesJson = '{"Name":"Account 1"}';

        CreateCustomObjectAction.CreateRecordInput input2 = new CreateCustomObjectAction.CreateRecordInput();
        input2.objectApiName = 'Account';
        input2.fieldValuesJson = '{"Name":"Account 2"}';

        List<CreateCustomObjectAction.CreateRecordInput> inputs = new List<CreateCustomObjectAction.CreateRecordInput>{input1, input2};

        // Act
        Test.startTest();
        List<CreateCustomObjectAction.CreateRecordOutput> outputs = CreateCustomObjectAction.createRecord(inputs);
        Test.stopTest();

        // Assert
        System.assertEquals(2, outputs.size(), 'Should return two outputs');
        for (CreateCustomObjectAction.CreateRecordOutput output : outputs) {
            System.assertEquals(true, output.isSuccess, 'Should be successful');
            System.assertNotEquals(null, output.recordId, 'Record ID should be set');
        }

        // Verify records were created
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN (:outputs[0].recordId, :outputs[1].recordId)];
        System.assertEquals(2, accounts.size(), 'Should have created two accounts');
    }
}

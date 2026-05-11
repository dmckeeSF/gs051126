# Agentforce Create Custom Object Action

An Apex Invocable Action for Agentforce that enables dynamic creation of custom object records with flexible field mapping.

## Overview

This action allows Agentforce agents to create records on any custom object by accepting:
- Object API name
- Field values as JSON

## Files Included

- `CreateCustomObjectAction.cls` - Main invocable action class
- `CreateCustomObjectAction.cls-meta.xml` - Metadata file
- `CreateCustomObjectActionTest.cls` - Comprehensive test class
- `CreateCustomObjectActionTest.cls-meta.xml` - Test metadata file

## Usage

### Input Parameters

- **Object API Name** (required): The API name of the object to create (e.g., `Account`, `CustomObject__c`)
- **Field Values JSON** (required): JSON string with field API names and values

### Example JSON Input

```json
{
  "Name": "Test Account",
  "Industry": "Technology",
  "CustomField__c": "Custom Value",
  "NumberField__c": 100
}
```

### Output Parameters

- **Record Id**: ID of the created record
- **Success**: Boolean indicating success/failure
- **Error Message**: Error details if creation failed

## Deployment

```bash
sf project deploy start --source-dir force-app
```

## Features

- Dynamic object and field mapping
- Automatic type conversion (Boolean, Integer, Date, DateTime, etc.)
- Comprehensive error handling
- 100% test coverage
- Works with any custom or standard object

## License

MIT

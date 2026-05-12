# Agentforce Create Opportunity Action

Field Set-based Apex Invocable Actions for Agentforce that enable intelligent Opportunity creation with customer-configurable fields.

## Overview

This ISV solution provides two Agentforce actions:
1. **Create Opportunity** - Creates Opportunities with fields defined in a Field Set
2. **Get Opportunity Fields** - Returns available fields with metadata for agent discovery

Customers can configure which Opportunity fields are available by modifying the `Agentforce_Create_Fields` Field Set.

## Files Included

### Apex Classes
- `CreateCustomObjectAction.cls` - Main action for creating Opportunities
- `CreateCustomObjectActionTest.cls` - Comprehensive test class
- `GetOpportunityFieldsAction.cls` - Action for field discovery
- `GetOpportunityFieldsActionTest.cls` - Test class for field discovery

### Field Set
- `Opportunity.Agentforce_Create_Fields` - Defines available fields for Opportunity creation

## Usage

### 1. Get Available Fields (Agent Discovery)

The agent first calls `Get Opportunity Fields` to understand what fields are available:

**Output Example:**
```json
[
  {
    "apiName": "Name",
    "label": "Opportunity Name",
    "fieldType": "STRING",
    "isRequired": true,
    "helpText": null,
    "picklistValues": null
  },
  {
    "apiName": "StageName",
    "label": "Stage",
    "fieldType": "PICKLIST",
    "isRequired": true,
    "picklistValues": "Prospecting, Qualification, Needs Analysis, Value Proposition, Closed Won, Closed Lost"
  }
]
```

### 2. Create Opportunity

The agent then calls `Create Opportunity` with field values as JSON:

**Input Example:**
```json
{
  "Name": "Enterprise Deal",
  "StageName": "Qualification",
  "CloseDate": "2026-12-31",
  "Amount": 250000,
  "Description": "Large enterprise customer opportunity"
}
```

**Output:**
- `recordId` - ID of the created Opportunity
- `isSuccess` - Boolean indicating success
- `errorMessage` - Error details if creation failed

## Configuration

### Default Field Set

The package includes a default Field Set with these fields:
- **Name** (required)
- **StageName** (required)
- **CloseDate** (required)
- Amount
- Description
- Type
- LeadSource
- NextStep

### Customizing for Your Customers

Each customer can customize the Field Set via Setup:
1. Go to **Setup → Object Manager → Opportunity → Field Sets**
2. Edit **Agentforce_Create_Fields**
3. Add/remove fields as needed
4. Mark fields as required if necessary

## Deployment

```bash
sf project deploy start --source-dir force-app
```

## Features

- ✅ **Field Set-based configuration** - Declarative, customer-friendly
- ✅ **ISV-ready** - Packageable and customer-configurable
- ✅ **Automatic validation** - Validates fields against Field Set
- ✅ **Type conversion** - Handles Boolean, Integer, Date, DateTime, Decimal
- ✅ **Picklist discovery** - Returns valid picklist values to agent
- ✅ **Required field checking** - Validates all required fields are populated
- ✅ **100% test coverage** - Comprehensive test classes included

## Agent Instructions

When configuring your Agentforce agent, instruct it to:
1. Call `Get Opportunity Fields` to discover available fields
2. Ask the user for required field values
3. Call `Create Opportunity` with the collected values

## License

MIT

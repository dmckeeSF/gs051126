# Agentforce Create Opportunity Action

Field Set-based Apex Invocable Actions for Agentforce that enable intelligent Opportunity creation with customer-configurable fields.

## Overview

This ISV solution provides two Agentforce actions:
1. **Get Opportunity Fields** - Returns available fields with metadata for agent discovery
2. **Create Opportunity** - Creates Opportunities with fields defined in a Field Set

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
3. Add/remove fields as needed (including custom fields)
4. Mark fields as required if necessary

**The agent will automatically discover changes** - no code updates needed!

## Deployment

```bash
sf project deploy start --source-dir force-app
```

## Features

- ✅ **Field Set-based configuration** - Declarative, customer-friendly
- ✅ **ISV-ready** - Packageable and customer-configurable
- ✅ **Dynamic field discovery** - Agent adapts to each customer's Field Set
- ✅ **Automatic validation** - Validates fields against Field Set
- ✅ **Type conversion** - Handles Boolean, Integer, Date, DateTime, Decimal
- ✅ **Picklist discovery** - Returns valid picklist values to agent
- ✅ **Required field checking** - Validates all required fields are populated
- ✅ **Custom field support** - Customers can add their own fields
- ✅ **100% test coverage** - Comprehensive test classes included

## Agent Instructions

When configuring your Agentforce agent, instruct it to:
1. Call `Get Opportunity Fields` to discover available fields
2. Identify which fields are required
3. Ask the user for required field values
4. Optionally ask for additional field values
5. Call `Create Opportunity` with the collected values

Example agent instruction:
```
Before creating an opportunity, always call "Get Opportunity Fields" to see what 
fields are available and which are required. Use the field labels and help text 
to ask the user for appropriate values. For picklist fields, present the valid 
options to the user.
```

## Error Handling

The actions return descriptive errors for:
- Missing required fields
- Fields not in Field Set
- Invalid field names
- Type conversion errors
- Invalid JSON format
- Field Set not found

## Why Two Actions?

The two-action pattern enables **dynamic adaptation** to each customer's configuration:
- Customer A adds custom field `Contract_Term__c` → agent automatically discovers it
- Customer B customizes Stage picklist values → agent sees the correct options
- No hard-coded field lists in agent instructions
- Each customer's agent adapts to their specific Opportunity structure

## License

MIT

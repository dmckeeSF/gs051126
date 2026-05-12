# Agentforce Create Opportunity Action

Hybrid Custom Metadata + Field Set solution for Agentforce that enables intelligent Opportunity creation with flexible, multi-team configurations.

## Overview

This ISV solution provides two Agentforce actions with support for multiple named configurations:
1. **Get Opportunity Fields** - Returns available fields with metadata
2. **Create Opportunity** - Creates Opportunities with validated fields

Each configuration references a Field Set, allowing customers to define different field sets for different teams (e.g., Sales Team, Partner Team).

## Architecture: Hybrid Approach (Option 3)

**Custom Metadata Type** (`Agentforce_Opp_Config__mdt`) stores named configurations:
- `Label`: User-friendly name (e.g., "Sales Team", "Partner Team")
- `Field_Set_Name__c`: References an Opportunity Field Set
- `Description__c`: Configuration purpose

**Field Sets** define the actual fields declaratively.

**Benefits:**
- ✅ Multiple named configurations for different teams
- ✅ Field Sets remain declarative and user-friendly
- ✅ Agent specifies which configuration to use
- ✅ ISV packageable with customer customization

## Files Included

### Apex Classes
- `CreateCustomObjectAction.cls` - Creates Opportunities
- `CreateCustomObjectActionTest.cls` - Test class
- `GetOpportunityFieldsAction.cls` - Returns field metadata
- `GetOpportunityFieldsActionTest.cls` - Test class

### Custom Metadata Type
- `Agentforce_Opp_Config__mdt` - Configuration object
- `Agentforce_Opp_Config.Default` - Default configuration record

### Field Set
- `Opportunity.Agentforce_Create_Fields` - Default field set

## Usage

### 1. Get Available Fields

```json
Input: {
  "configurationName": "Default"
}

Output: {
  "fieldsJson": "[{\"apiName\":\"Name\",\"label\":\"Opportunity Name\",\"fieldType\":\"STRING\",\"isRequired\":true,...}]",
  "isSuccess": true
}
```

### 2. Create Opportunity

```json
Input: {
  "configurationName": "Default",
  "fieldValuesJson": "{\"Name\":\"Enterprise Deal\",\"StageName\":\"Qualification\",\"CloseDate\":\"2026-12-31\"}"
}

Output: {
  "recordId": "006...",
  "isSuccess": true
}
```

## Configuration

### For ISV: Package Default Setup

Include in your package:
1. Default CMT record pointing to default Field Set
2. Default Field Set with standard Opportunity fields

### For Customers: Add Team-Specific Configs

1. Go to **Setup → Custom Metadata Types → Agentforce Opportunity Configuration**
2. Click **Manage Records** → **New**
3. Create configuration (e.g., "Sales_Team")
4. Create a Field Set: **Setup → Object Manager → Opportunity → Field Sets**
5. Link configuration to Field Set

**Example Multi-Team Setup:**
- **Sales_Team** → References `Sales_Opportunity_Fields` Field Set
- **Partner_Team** → References `Partner_Opportunity_Fields` Field Set
- **Default** → References `Agentforce_Create_Fields` Field Set

## Deployment

```bash
sf project deploy start --source-dir force-app
```

## Features

- ✅ **Multi-team support** - Different configurations for different teams
- ✅ **Hybrid architecture** - CMT + Field Sets
- ✅ **ISV-ready** - Packageable and customer-configurable
- ✅ **Dynamic discovery** - Agent adapts to configuration
- ✅ **Field-level security** - Respects user permissions (`with sharing`)
- ✅ **Type conversion** - Handles all Salesforce field types
- ✅ **Picklist discovery** - Returns valid values
- ✅ **100% test coverage**

## Agent Instructions

```
When creating an opportunity, first call "Get Opportunity Fields" with the 
appropriate configuration name (e.g., "Sales_Team" or "Default"). Use the 
returned field metadata to ask the user for values, then call "Create Opportunity" 
with the same configuration name.
```

## License

MIT
